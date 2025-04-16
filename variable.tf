# ------ General Variables ------
# Name of the project, used as a prefix for naming resources.
variable "project_name" { 

}

# Deployment environment 
variable "project_environment" {

}

# Azure region where the resources will be deployed.
variable "location" {

}

# Common tags to be applied to all resources.
variable "tags" { 

}

variable "resource_group_name" {
  
}
variable "resource_group_id" {
  
}

# ------ Virtual Network (VNet) ------
# Address space for the virtual network.
variable "vnet_address_space" { 

}

# Subnet CIDR block within the VNet.
variable "subnet_cidr" {

}

# ------ Azure SQL Database ------
# Maximum size of the SQL database in GB.
variable "max_size_gb" {

}

# SKU tier for the Azure SQL database.
variable "sql_sku_name" {

}

# ------ Azure Kubernetes Service (AKS) ------
# Version of Kubernetes to deploy.
variable "kubernetes_version" {

}

# SKU tier for AKS 
variable "aks_sku_tier" {

}

# Minimum number of nodes in the AKS node pool.
variable "nodepool1-mincount" {

}

# Maximum number of nodes in the AKS node pool.
variable "nodepool1-maxcount" {

}

# Virtual machine size for AKS nodes.
variable "vm_size" {

}

# ------ Static Web App ------
# SKU tier for the Azure Static Web App.
variable "static_web_app_sku_tier" {

}

# ------ Application Insights ------
# Data retention period in days for Application Insights.
variable "retention_in_days" {

}

# SKU tier for the Log Analytics workspace.
variable "workspace_sku" {

}

# ------ Azure DevOps Variables ------
# Personal Access Token (PAT) for Azure DevOps authentication.
variable "azure_devops_pat" {

}

# Name of the container image.
variable "image_name" {

}

# Tag for the container image.
variable "image_tag" {

}


variable "host_name_admin" {
  
}
variable "host_name_borrower" {
  
}
variable "host_name_api" {
  
}
# Name of the Azure DevOps project.
variable "azure_devops_project_name" {

}

variable "github_service_connection" {
  
}

variable "build_dir" {
  
}
variable "subscription_name" {
  
}
# Azure DevOps branch used for deployments.
variable "branch_admin" {
  
}
variable "branch_borrower" {
  
}
variable "branch_api" {
  
}
