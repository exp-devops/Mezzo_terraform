# The name of the project, used for resource naming and organization.
variable "project_name" {
  
}

# The environment of the project (e.g., dev, staging, prod). 
variable "project_environment" {
  
}

# The name of the Azure DevOps project.
variable "devopsprojectname" {
  
}


# The name of the Azure Container Registry (ACR) where images will be stored.
variable "acr_name" {
  
}

# The name of the container image to be deployed.
variable "image_name" {
  
}

# The Azure Resource Group where AKS and related resources are deployed.
variable "rg_mezzo" {
  
}

# The name of the Azure Kubernetes Service (AKS) cluster.
variable "aks_cluster" {
  
}

# The tag of the container image, usually representing a specific build or version.
variable "image_tag" {
  
}
# GitHub service connection
variable "github_service_connection" {
  
}
# Deployment token for admin
variable "deployment_token_admin" {
  
}
# Deployment token for borrower
variable "deployment_token_borrower" {
  
}
# build directory
variable "build_dir" {
  
}
# ACR URL
variable "acr_url" {
  
}
# ACR admin username
variable "acr_admin_username" {
  
}
# ACR admin password
variable "acr_admin_password" {
  
}
# AKS API URL
variable "aks_api_url" {
  
}
# ID of resource group where resources are deployed.
variable "rg_mezzo_id" {
  
}
# AKS name.
variable "aks_cluster_name" {
  
}
# Azure Subscription name
variable "subscription_name" {
  
}

# The Git branch to be used for deployment.
variable "branch_admin" {
  
}
variable "branch_borrower" {
  
}
variable "branch_api" {
  
}
