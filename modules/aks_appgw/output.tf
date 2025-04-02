output "client_key" {
  description = "Client key of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Client CA certificate of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Host name of Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "appgw_public_ip" {
    value = azurerm_public_ip.appgw_pip.ip_address
  
}
output "appgw_name" {
    value = azurerm_application_gateway.appgw.name
  
}

output "aks_cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}