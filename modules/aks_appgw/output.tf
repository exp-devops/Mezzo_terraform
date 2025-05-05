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
# Output of aks secret identity
output "aks_secret_identity" {
  value = data.azurerm_kubernetes_cluster.aks_data.key_vault_secrets_provider[0].secret_identity[0].object_id
}
# Output of aks tenant ID
output "aks_tenantid" {
  value = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
}
# Output of aks object ID
output "aks_objectid" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
# Output of vmss_uami principal ID
output "vmss_uami" {
  value = data.azurerm_user_assigned_identity.uami.principal_id
  
}
