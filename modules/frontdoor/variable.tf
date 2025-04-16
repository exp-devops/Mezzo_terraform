# The name of the project
variable "project_name" {
  
}

# The environment of the project 
variable "project_environment" {
  
}

# The Azure region where resources will be deployed
variable "location" {
  
}

# tags to apply to resources
variable "tags" {
  
}

# The Azure Resource Group where all related resources are deployed.
variable "rg_mezzo" {
  
}

# The URL of the Static Web App for the admin portal.
variable "static_web_app_url_admin" {
  
}

# The URL of the Static Web App for the borrower portal.
variable "static_web_app_url_borrower" {
  
}

# The public IP address assigned to the Azure Application Gateway.
variable "appgw_ip" {
  
}

variable "host_name_admin" {
  
}

variable "host_name_borrower" {
  
}
variable "host_name_api" {
  
}