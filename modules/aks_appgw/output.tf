# Output Of Client key of Kubernetes cluster.
output "client_key" {
  description = "Client key of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}
# Output of Client certificate of Kubernetes cluster.
output "client_certificate" {
  description = "Client certificate of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}
# Output of Client CA certificate of Kubernetes cluster.
output "cluster_ca_certificate" {
  description = "Client CA certificate of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}
# Output of Host name of Kubernetes cluster.
output "host" {
  description = "Host name of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}
# Output application gateway Public IP.
/*
output "appgw_public_ip" {
    value     = azurerm_public_ip.appgw_pip.ip_address
  
}
# Output application gateway Name.
output "appgw_name" {
    value = azurerm_application_gateway.appgw.name
  
}*/
# Output of Kubernetes cluster name.
output "aks_cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}
# Output of Kubernetes api url.
output "aks_api_url" {
  value= azurerm_kubernetes_cluster.aks.fqdn
  
}
# Output of application gateway.
output "appgw_ip" {
  value = data.azurerm_public_ip.appgw_public_ip.ip_address
  
}
output "aks_secret_identity" {
  value = data.azurerm_kubernetes_cluster.aks_data.key_vault_secrets_provider[0].secret_identity[0].object_id
}
output "aks_tenantid" {
  value = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
}
output "aks_objectid" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
output "vmss_uami" {
  value = data.azurerm_user_assigned_identity.uami.principal_id
  
}
