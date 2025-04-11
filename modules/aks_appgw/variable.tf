# Name of the project 
variable "project_name" { 

}

# Deployment environment 
variable "project_environment" {

}

# Azure region where resources will be deployed 
variable "location" {

}

# ID of the first public subnet where AKS nodes might be deployed
variable "publicsubnet1_id" {

}

# ID of the second public subnet, used for Application Gateway or other resources
variable "publicsubnet2_id" {

}

# Name of the resource group where resources will be deployed
variable "rg_mezzo" { 

}

# Tags for organizing and managing resources in Azure
variable "tags" {

}

# Version of Kubernetes to be deployed in AKS 
variable "kubernetes_version" {

}

# AKS SKU tier 
variable "aks_sku_tier" {

}

# Virtual machine size for the AKS node pool 
variable "vm_size" {

}

# Minimum number of nodes in the first node pool
variable "nodepool1-mincount" {

}

# Maximum number of nodes in the first node pool 
variable "nodepool1-maxcount" {

}
/*
# Azure Active Directory (AAD) tenant ID for authentication
variable "tenant_id" {

}

# Azure subscription ID where the infrastructure will be deployed
variable "subscription_id" {

}*/

# Azure Container Registry (ACR) ID for storing container images
variable "acr_id" {

}
variable "rg_mezzo_id" {
  
}

