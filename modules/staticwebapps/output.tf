# Output Static Web App URL
output "static_web_app_url_admin" {
  value = azurerm_static_site.tf_admin_webapp.default_host_name
}

# Output Deployment Token
output "static_web_app_deployment_token_admin" {
  value     = azurerm_static_site.tf_admin_webapp.api_key
  sensitive = true
}

# Output Static Web App URL
output "static_web_app_url_borrower" {
  value = azurerm_static_site.tf_borrow_webapp.default_host_name
}

# Output Deployment Token
output "static_web_app_deployment_token_borrow" {
  value     = azurerm_static_site.tf_borrow_webapp.api_key
  sensitive = true
}