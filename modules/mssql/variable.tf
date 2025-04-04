# The name of the project
variable "project_name" {  
}

# The deployment environment 
variable "project_environment" {  
}

# The Azure region where resources will be deployed 
variable "location" {  
}

# Tags to apply to resources 
variable "tags" {  
}

# The name of the Azure Resource Group where resources will be deployed.
variable "rg_mezzo" {  
}

# The SKU for the Azure SQL Database.
variable "sql_sku_name" {  
}

# The maximum storage size (in GB) for the Azure SQL Database.
variable "max_size_gb" {  
}

# The Azure Key Vault ID where sensitive secrets, such as passwords, will be stored.
variable "vault_id" {  
}

# The ID of the private subnet where the Azure SQL Private Endpoint will be deployed.
variable "privatesubnet1_id" {  
    
}

# The ID of the Virtual Network (VNet) 
variable "vnet_id" { 

}