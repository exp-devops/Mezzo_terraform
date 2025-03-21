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
