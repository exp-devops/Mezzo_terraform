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

output "aks_cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}

output "aks_api_url" {
  value= azurerm_kubernetes_cluster.aks.kube_config[0].host
  
}
output "appgw_ip" {
  value = data.azurerm_public_ip.appgw_public_ip.ip_address
  
}