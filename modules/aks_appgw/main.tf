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
  # Enable OMS Agent to send logs and metrics to Log Analytics
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace  # Link to Log Analytics Workspace
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
# Assign AKS permission for log_analytics_workspace
resource "azurerm_role_assignment" "aks_log_analytics_reader" {
  scope                            = var.log_analytics_workspace
  role_definition_name             = "Log Analytics Reader"  # Ensures AKS can access log data
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id    
}

# Assign AKS permission to access Application Insights
resource "azurerm_role_assignment" "aks_application_insights_reader" {
  scope                            = var.azure_application_insights_id
  role_definition_name             = "Monitoring Reader"  # Ensures AKS can access Application Insights telemetry
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
# Node resource group
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
# aks_data
data "azurerm_kubernetes_cluster" "aks_data" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
}
# Application Gateway
data "azurerm_application_gateway" "appgw" {
  name = "${var.project_name}-${var.project_environment}-appgateway"
  resource_group_name = "MC_${var.rg_mezzo}" 
  depends_on = [ azurerm_kubernetes_cluster.aks, azurerm_role_assignment.agic_network_contributor] 
  
}
# Application Gateway ingress controller network contributor.
resource "azurerm_role_assignment" "agic_network_contributor" {
  scope                = var.publicsubnet2_id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.aks_data.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
# Application Gateway ingress controller network contributor.
data "azurerm_public_ip" "appgw_public_ip" {
  name = "${var.project_name}-${var.project_environment}-appgateway-appgwpip"
  resource_group_name = "MC_${var.rg_mezzo}"  
  depends_on = [azurerm_kubernetes_cluster.aks, data.azurerm_application_gateway.appgw]  
  
}
# kubernetes namespace
resource "kubernetes_namespace" "api_namespace" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  metadata {
    name = "${var.project_name}-${var.project_environment}"
  }
}
# Assign AKS permission to access key vault
resource "azurerm_role_assignment" "keyvault" {
  scope                            = var.vault_id                                                     
  role_definition_name             = "Key Vault Administrator"                                                      
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id    
}
# user assigned managed identity
data "azurerm_user_assigned_identity" "uami" {
  name                = "${var.project_name}-${var.project_environment}-aks-cluster-agentpool"        # name = "aksname"-agentpool
  resource_group_name = "MC_${var.rg_mezzo}"    
}
