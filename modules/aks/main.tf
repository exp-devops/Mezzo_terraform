locals {
  common_tags             = var.tags
}
/*
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.project_name}-${var.project_environment}-log-analytics"
  location            = var.location
  resource_group_name = var.rg_mezzo
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
*/
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
    vnet_subnet_id      = var.privatesubet1_id
    
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

  azure_active_directory_role_based_access_control {
    managed            = true
    tenant_id          = "05cb6afc-e5de-470e-ad06-4a5b08adfcd8"
    azure_rbac_enabled = true

  }

    network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }
 
  /*microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }*/

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}
/*

resource "azurerm_kubernetes_cluster_extension" "container_insights" {
  name                         = "ContainerInsights"
  cluster_id                   = azurerm_kubernetes_cluster.aks.id
  extension_type               = "Microsoft.AzureMonitor.Containers"
}*/

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Placeholder for alert rule
/*resource "azurerm_monitor_metric_alert" "aks_cpu_alert" {
  name                = "${var.project_name}-${var.project_environment}-cpu-alert"
  resource_group_name = var.rg_mezzo
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Alert for high CPU usage"
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"
  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name       = "CPUUsage"
    aggregation       = "Average"
    operator          = "GreaterThan"
    threshold         = 80
  }
  action {
    #action_group_id = var.alert_action_group_id
    action_group_id = azurerm_monitor_action_group.aks_alerts.id
  }
}
resource "azurerm_monitor_action_group" "aks_alerts" {
  name                = "${var.project_name}-${var.project_environment}-aks-alert-ag"
  resource_group_name = var.rg_mezzo
  short_name          = "aksalerts"

  email_receiver {
    name                    = "DevOpsTeamEmail"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
 tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-aks-alert-ag"}
  )
  
}*/
