# Output Azure Application Insights instrumentation key
output "azure_application_insights_instrumentation_key" {
  value       = azurerm_application_insights.application_insights.instrumentation_key
  description = "The Azure Application Insights instrumentation key"
}
# Output Azure Application Insights connection string
output "azure_application_insights_connection_string" {
  value       = azurerm_application_insights.application_insights.connection_string
  description = "The Azure Application Insights connection string"
}
# Output Azure Application Insights name
output "azure_application_insights_name" {
  value       = azurerm_application_insights.application_insights.name
  description = "The Azure Application Insights name"
}
# Output log analytics workspace ID
output "log_analytics_workspace" {
    value = azurerm_log_analytics_workspace.log_analytics_workspace.id  
}
# Output of Azure application insights ID
output "azure_application_insights_id" {
  value = azurerm_application_insights.application_insights.id
  
}