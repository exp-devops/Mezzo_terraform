# Modules for Resource Group
module "rg" {
  source = "./modules/rg"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  tags = var.tags
}
# Modules for Virtual Network
module "vnet" {
  source = "./modules/vnet"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  vnet_address_space =var.vnet_address_space
  subnet_cidr = var.subnet_cidr
  tags = var.tags 
}
# Modules for Key Vault
module "keyvault" {
  source = "./modules/keyvault"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
}
# Modules for MS SQL
module "mssql" {
  source = "./modules/mssql"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
  vault_id = module.keyvault.vault_id
  max_size_gb = var.max_size_gb
  sql_sku_name = var.sql_sku_name
  vnet_id = module.vnet.vnet_id
  privatesubet1_id = module.vnet.privatesubet1_id
}

# Modules for ACR
module "acr" {
 source = "./modules/acr"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
  vnet_id = module.vnet.vnet_id
  privatesubet1_id = module.vnet.privatesubet1_id
}

# Modules for AKS
module "aks" {
 source = "./modules/aks"
 project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  privatesubet1_id = module.vnet.privatesubet1_id
  tags = var.tags 
  nodepool1-maxcount = var.nodepool1-maxcount
  nodepool1-mincount = var.nodepool1-mincount
  acr_id = module.acr.acr_id
  kubernetes_version = var.kubernetes_version
  vm_size = var.vm_size
  aks_sku_tier = var.aks_sku_tier
  log_analytics_workspace = module.applicationinsights.log_analytics_workspace
}

# Modules for Static Web App
module "staticwebapps"{
  source = "./modules/staticwebapps"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
  static_web_app_sku_tier = var.static_web_app_sku_tier

}

# Modules for Application Insights
module "applicationinsights"{
  source = "./modules/applicationinsights"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
  workspace_sku = var.workspace_sku
  retention_in_days = var.retention_in_days

}

# Modules for Front Door
module "frontdoor"{
  source = "./modules/frontdoor"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
  static_web_app_url_admin = module.staticwebapps.static_web_app_url_admin
  static_web_app_url_borrower = module.staticwebapps.static_web_app_url_borrower
  appgw_public_ip = module.applicationgateway.appgw_public_ip
}

# Modules for Application Gateway
module "applicationgateway" {
  source = "./modules/applicationgateway"
  project_name =var.project_name
  project_environment = var.project_environment
   location = var.location
  rg_mezzo = module.rg.rg_mezzo
  publicsubet1_id = module.vnet.publicsubet1_id
}

