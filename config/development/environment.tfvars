project_name           = "mezzo"
project_environment    = "dev"
location               = "eastus2"

resource_group_name    = "CNB_DEV"
resource_group_id      = "/subscriptions/ef370afa-d8de-4af2-a91d-7be5a40ab513/resourceGroups/CNB_DEV"

tags = {
  "Project"            = "mezzo"
  "Environment"        = "development"
  "Description"        = "By Terraform"
  "Product"            = "mezzo"
}
# ---------------vnet-----------------------------------
vnet_address_space = ["10.1.0.0/16"]
subnet_cidr = {
  "SUBNET_01" = ["10.1.0.0/24"]
  "SUBNET_02" = ["10.1.1.0/24"]
  "SUBNET_03" = ["10.1.2.0/24"]
  "SUBNET_04" = ["10.1.3.0/24"]
}
#-------------- mssql --------------------------------
version = 15.0
max_size_gb = 2
#sql_sku_name = "HS_Gen5_2"
sql_sku_name  = "Basic"
#-------------aks----------------------------------
nodepool1-maxcount = 1
nodepool1-mincount = 1
kubernetes_version = "1.31.7" 
#kubernetes_version  = "1.28.3"
vm_size = "Standard_DS2_v2"
aks_sku_tier = "Standard"

static_web_app_sku_tier = "Standard"

workspace_sku = "PerGB2018"
retention_in_days = 30
#tenant_id          = "05cb6afc-e5de-470e-ad06-4a5b08adfcd8"
#subscription_id = "ef370afa-d8de-4af2-a91d-7be5a40ab513"

#------------------- Azure pipeline-----------------
azure_devops_pat = "3lj74aLgsdyuNtZAF3VC2x3JxMijsjcax3S92VoqYpOs9MUaKBQHJQQJ99BDACAAAAAHIKsPAAASAZDOl74C"

image_name = "core-service"
  
image_tag = "latest"
#branch = "Nirupama-Suresh-patch-3"
  
azure_devops_project_name = "CNB"
github_service_connection = "6ad1ec3c-d90f-420c-b4dc-73147d178394"
build_dir = "dist"
subscription_name = "cnb_dev"

branch_admin = "main"
branch_borrower = "main"
branch_api = "main"

host_name_admin = "cnb-dev-ap.dev.teammezzo.com"
host_name_borrower = "cnb-dev-bp.dev.teammezzo.com"
host_name_api = "cnb-posapi.dev.teammezzo.com"