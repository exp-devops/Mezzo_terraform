# Common tags to apply to all resources
locals {
  common_tags                = var.tags
}
/*
# Deploys an Elastic Cloud Elasticsearch instance for log analytics and search capabilities
resource "azurerm_elastic_cloud_elasticsearch" "mezzo" {
  name                        = "${var.project_name}-${var.project_environment}-elasticsearch"   
  resource_group_name         = var.rg_mezzo                                                     
  location                    = var.location                                                     
  sku_name                    = "ess-consumption-2024_Monthly"                                   
  elastic_cloud_email_address = "nirupama.suresh@experionglobal.com"                              
  monitoring_enabled          = true                                                              
  
                                          
# Configures log forwarding to Azure services
  logs {
    send_activity_logs        = true                                                                
    send_azuread_logs         = true                                                                 
    send_subscription_logs    = true                                                               
}
}*/