# Common tags to apply to all resources
locals {
  common_tags                      = var.tags
}
 #Azure Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                             = "${var.project_name}-${var.project_environment}-aks-cluster"        
  location                         = var.location                                                        
  resource_group_name              = var.rg_mezzo                                                       
  dns_prefix                       = "${var.project_name}-${var.project_environment}-dns"                
  kubernetes_version               = var.kubernetes_version                                                
  sku_tier                         = var.aks_sku_tier                                                    
  private_cluster_enabled          = false                                                               
  node_resource_group              = "MC_${var.rg_mezzo}"                                                
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-aks-cluster"}             
  )

# Default node pool
  default_node_pool {
    name                           = "${var.project_name}${var.project_environment}1"                   # Unique name for the node pool
    vm_size                        =  var.vm_size                                                       
    zones                          = ["1", "2"]                                                         
    enable_auto_scaling            = true                                                               # Enable auto-scaling for the node pool
    min_count                      = var.nodepool1-mincount                                             
    max_count                      = var.nodepool1-maxcount                                             
    vnet_subnet_id                 = var.publicsubnet1_id                                               
    
    node_labels = {
      environment                  = "dev"                                                      
    }
    upgrade_settings {
      max_surge                    = "33%"                                                              # Controls the number of nodes upgraded simultaneously
    }
  }
   
  
  identity {
    type                           = "SystemAssigned"                                                  # Use system-assigned managed identity for authentication
  }


  network_profile {
    network_plugin                 = "azure"                                                           
    network_policy                 = "azure"                                                           
    load_balancer_sku              = "standard"                                                 
  }

  key_vault_secrets_provider {
    secret_rotation_enabled        = true                                                             # Enables automatic rotation of secrets stored in Azure Key Vault
  }
  

  lifecycle {
    ignore_changes                 = [default_node_pool[0].node_count]                                # Ignore changes to node count to prevent Terraform drift
  }
 
  ingress_application_gateway {
    
    gateway_name = "${var.project_name}-${var.project_environment}-appgateway"
    subnet_id  = var.publicsubnet2_id
    
  
}
}

data "azurerm_resource_group" "node_resource_group_mezzo" {
  name = "MC_${var.rg_mezzo}"   
  depends_on = [ azurerm_kubernetes_cluster.aks ] 

}

# Assign AKS permission to pull images from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                            = var.acr_id                                                      
  role_definition_name             = "AcrPull"                                                       
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id    
}
data "azurerm_kubernetes_cluster" "aks_data" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
}
data "azurerm_application_gateway" "appgw" {
  name = "${var.project_name}-${var.project_environment}-appgateway"
  resource_group_name = "MC_${var.rg_mezzo}" 
  depends_on = [ azurerm_kubernetes_cluster.aks, azurerm_role_assignment.agic_network_contributor] 
  
}

resource "azurerm_role_assignment" "agic_network_contributor" {
  scope                = var.publicsubnet2_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.aks_data.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

data "azurerm_public_ip" "appgw_public_ip" {
  name = "${var.project_name}-${var.project_environment}-appgateway-appgwpip"
  resource_group_name = "MC_${var.rg_mezzo}"  
  depends_on = [azurerm_kubernetes_cluster.aks, data.azurerm_application_gateway.appgw]  
  
}

resource "kubernetes_namespace" "api_namespace" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  metadata {
    name = "${var.project_name}-${var.project_environment}"
  }
}
 

/*
resource "kubernetes_namespace" "api_namespace" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  metadata {
    name = "${var.project_name}-${var.project_environment}"
  }
}*/

/*
resource "azurerm_role_assignment" "agic_contributor_rg_mc" {
  scope                = data.azurerm_resource_group.node_resource_group_mezzo.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [principal_id] # Optional, if managed identity might be changed externally
  }
}*/

/*
# Public IP address for the Application Gateway.
resource "azurerm_public_ip" "appgw_pip" {
  name                             = "${var.project_name}-${var.project_environment}-appgw-public-ip"   
  resource_group_name              = var.rg_mezzo                                                       
  location                         = var.location                                                       
  allocation_method                = "Static"                                                           
  sku                              = "Standard"                                                         
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-appgw-public-ip"}
  )
}
# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                             = "${var.project_name}-${var.project_environment}-app-gateway"       
  resource_group_name              = var.rg_mezzo                                                       
  location                         = var.location                                                       
  tags = merge(                                                                                         
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-app-gateway"}
  )
  
                                                     
# SKU (tier, type, and capacity) of the Application Gateway.
  sku {
    name                           = "Standard_v2"                                                      
    tier                           = "Standard_v2"                                                      
    capacity                       = 2                                                                  
  }
# Gateway's IP settings and associates it with Public subnet.
  gateway_ip_configuration {
    name                           = "${var.project_name}-${var.project_environment}-appgw-ip-config"   
    subnet_id                      = var.publicsubnet2_id                                               
  }
# Frontend IP configuration, using a public IP for external traffic.
  frontend_ip_configuration {                             
    name                           = "${var.project_name}-${var.project_environment}-appgw-frontend-ip" 
    public_ip_address_id           = azurerm_public_ip.appgw_pip.id                                     
  }
# Configures the port on which the Application Gateway listens for incoming requests.
  frontend_port {
    name                           = "${var.project_name}-${var.project_environment}-appgw-frontend-port"
    port                           = 80                                                                  
  }
# Defines the backend pool where incoming traffic will be forwarded.
backend_address_pool {
    name                           = "${var.project_name}-${var.project_environment}-appgw-backend-pool" 
    
  }

# Configures how the gateway communicates with the backend.
  backend_http_settings {
     name                          = "${var.project_name}-${var.project_environment}-appgw-http-setting" 
    cookie_based_affinity          = "Disabled"                                                          
    port                           = 80                                                                 
    protocol                       = "Http"                                                              
    request_timeout                = 20                                                                  # Maximum time (in seconds) to wait for a backend response
  }
# Defines an HTTP listener that accepts incoming traffic and links it to a frontend configuration.
  http_listener {
    name                          = "${var.project_name}-${var.project_environment}-appgw-http-listener"  
    frontend_ip_configuration_name = "${var.project_name}-${var.project_environment}-appgw-frontend-ip"   
    frontend_port_name             = "${var.project_name}-${var.project_environment}-appgw-frontend-port" 
    protocol                       = "Http"                                                              
  }
# Sets up request routing to direct incoming traffic to the backend.
  request_routing_rule {
    name                           = "${var.project_name}-${var.project_environment}-appgw-routing-rule"  
    rule_type                      = "Basic"
    http_listener_name             = "${var.project_name}-${var.project_environment}-appgw-http-listener" 
    backend_address_pool_name      = "${var.project_name}-${var.project_environment}-appgw-backend-pool"  
    backend_http_settings_name     = "${var.project_name}-${var.project_environment}-appgw-http-setting"  
    priority                       = 100                                                                  
  }
}
#---------------------------------aks------------------------------------------------
#  Azure Kubernetes Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                             = "${var.project_name}-${var.project_environment}-aks-cluster"        
  location                         = var.location                                                        
  resource_group_name              = var.rg_mezzo                                                       
  dns_prefix                       = "${var.project_name}-${var.project_environment}-dns"                
  kubernetes_version               = var.kubernetes_version                                                
  sku_tier                         = var.aks_sku_tier                                                    
  private_cluster_enabled          = false                                                               
  node_resource_group              = "MC_${var.rg_mezzo}"                                                
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-aks-cluster"}             
  )
# Default node pool
  default_node_pool {
    name                           = "${var.project_name}${var.project_environment}1"                   # Unique name for the node pool
    vm_size                        =  var.vm_size                                                       
    zones                          = ["1", "2"]                                                         
    enable_auto_scaling            = true                                                               # Enable auto-scaling for the node pool
    min_count                      = var.nodepool1-mincount                                             
    max_count                      = var.nodepool1-maxcount                                             
    vnet_subnet_id                 = var.publicsubnet1_id                                               
    
    node_labels = {
      environment                  = "dev"                                                      
    }
    upgrade_settings {
      max_surge                    = "33%"                                                              # Controls the number of nodes upgraded simultaneously
    }
  }
   
  
  identity {
    type                           = "SystemAssigned"                                                  # Use system-assigned managed identity for authentication
  }


  network_profile {
    network_plugin                 = "azure"                                                           
    network_policy                 = "azure"                                                           
    load_balancer_sku              = "standard"                                                 
  }

  key_vault_secrets_provider {
    secret_rotation_enabled        = true                                                             # Enables automatic rotation of secrets stored in Azure Key Vault
  }
  

  lifecycle {
    ignore_changes                 = [default_node_pool[0].node_count]                                # Ignore changes to node count to prevent Terraform drift
  }
  ingress_application_gateway {
    gateway_id                     = azurerm_application_gateway.appgw.id                             # Integrates AKS with Azure Application Gateway for Ingress
  }
}

# Assign AKS permission to pull images from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                            = var.acr_id                                                      
  role_definition_name             = "AcrPull"                                                       
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id    
}
/*
resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"      = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/backend-path-prefix" = "/"
      "appgw.ingress.kubernetes.io/use-private-ip"      = "true"
    }
  }

  spec {
    rule {
      host = "mezzo-dev-api.experionglobal.dev"
      http {
        path {
          backend {
            service {
              name = "core-service"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
  }
     depends_on = [azurerm_kubernetes_cluster.aks]
}*/
