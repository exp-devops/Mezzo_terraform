# The name of the project, used for resource naming and organization.
variable "project_name" {
  
}

# The environment of the project (e.g., dev, staging, prod). 
variable "project_environment" {
  
}

# The name of the Azure DevOps project.
variable "devopsprojectname" {
  
}

# The Git branch to be used for deployment.
variable "branch" {
  
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

variable "github_service_connection" {
  
}
