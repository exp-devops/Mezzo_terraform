project_name           = "mezzo"
project_environment    = "dev"
location               = "eastus2"

tags = {
  "Project"     = "mezzo"
  "Environment" = "dev"
  "Description" = "By Terraform"
  "Product"     = "mezzo"
}
#vnet
vnet_address_space = ["10.1.0.0/16"]
subnet_cidr = {
  "SUBNET_01" = ["10.1.0.0/24"]
  "SUBNET_02" = ["10.1.1.0/24"]
  "SUBNET_03" = ["10.1.2.0/24"]
  "SUBNET_04" = ["10.1.3.0/24"]
}
#mssql
version = 15.0
max_size_gb = 10
sql_sku_name = "HS_Gen5_2"

#aks
nodepool1-maxcount = 3
nodepool1-mincount = 2
kubernetes_version = "1.30.10"
vm_size = "Standard_DS2_v2"
aks_sku_tier = "Standard"

static_web_app_sku_tier = "Standard"

workspace_sku = "PerGB2018"
retention_in_days = 30

