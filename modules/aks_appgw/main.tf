resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.project_name}-${var.project_environment}-appgw-public-ip"
 
  resource_group_name = var.rg_mezzo
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
 # depends_on = [var.agic_dependency]
  name                = "${var.project_name}-${var.project_environment}-app-gateway"
  resource_group_name = var.rg_mezzo
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.project_name}-${var.project_environment}-appgw-ip-config"
    subnet_id = var.publicsubnet1_id
  }

  frontend_ip_configuration {
    name                 = "${var.project_name}-${var.project_environment}-appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "${var.project_name}-${var.project_environment}-appgw-frontend-port"
    port = 80
  }

backend_address_pool {
    name       = "${var.project_name}-${var.project_environment}-appgw-backend-pool"
    #ip_addresses = ["20.94.42.79"]
  }


  backend_http_settings {
     name                  = "${var.project_name}-${var.project_environment}-appgw-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
     name                           = "${var.project_name}-${var.project_environment}-appgw-http-listener"
    frontend_ip_configuration_name = "${var.project_name}-${var.project_environment}-appgw-frontend-ip"
    frontend_port_name             = "${var.project_name}-${var.project_environment}-appgw-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.project_name}-${var.project_environment}-appgw-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${var.project_name}-${var.project_environment}-appgw-http-listener"
    backend_address_pool_name  = "${var.project_name}-${var.project_environment}-appgw-backend-pool"
    backend_http_settings_name = "${var.project_name}-${var.project_environment}-appgw-http-setting"
    priority                   = 100  
  }
}
#-------aks--------
locals {
  common_tags             = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  
  name                = "${var.project_name}-${var.project_environment}-aks-cluster"
  location            = var.location
  resource_group_name = var.rg_mezzo
  dns_prefix          = "${var.project_name}-${var.project_environment}-dns"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.aks_sku_tier
  private_cluster_enabled = false
  node_resource_group = "MC_${var.rg_mezzo}"
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-aks-cluster"}
  )

  default_node_pool {
    name                = "${var.project_name}${var.project_environment}1"
    vm_size             =  var.vm_size  
    zones               = ["1", "2"]
    enable_auto_scaling = true
    min_count           = var.nodepool1-mincount
    max_count           = var.nodepool1-maxcount
    vnet_subnet_id      = var.privatesubnet1_id
    
    node_labels = {
      environment = "dev"
    }
    upgrade_settings {
      max_surge = "33%"
    }
  }
   
  
  identity {
    type = "SystemAssigned"
  }


  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }
/*
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace
  }*/

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }
}
/*
resource "azurerm_role_assignment" "aks_admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = "fbdb9a91-c6bb-41a2-a2df-b195aeb2a756"  # Replace with your user/service principal ID
}*/



# Assign AKS permission to pull images from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
/*
resource "azurerm_kubernetes_cluster_extension" "agic" {
  name             = "appgw-ingress-controller"
  cluster_id       = azurerm_kubernetes_cluster.aks.id
  extension_type   = "Microsoft.ApplicationGatewayIngressController"

  configuration_settings = {
    "appgw.name"                = azurerm_application_gateway.appgw.name
    "appgw.resourceGroup"       = var.rg_mezzo
    "appgw.subscriptionId"      = var.subscription_id
    "appgw.shared"              = "true"
  }
}*/
/*
resource "azurerm_role_assignment" "agic_contributor" {
  scope                = azurerm_application_gateway.appgw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
resource "azurerm_role_assignment" "agic_rg_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_mezzo}" # Assign to the AKS Resource Group
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}*/
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
      host = "myapp.example.com"
      http {
        path {
          backend {
            service {
              name = "myapp-service"
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
     depends_on = [azurerm_kubernetes_cluster.aks, azurerm_role_assignment.agic_contributor, azurerm_role_assignment.agic_rg_contributor]
}*/















