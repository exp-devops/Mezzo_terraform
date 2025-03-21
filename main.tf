module "rg" {
  source = "./modules/rg"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  tags = var.tags
}

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

module "keyvault" {
  source = "./modules/keyvault"
  project_name = var.project_name
  project_environment = var.project_environment
  location = var.location
  rg_mezzo = module.rg.rg_mezzo
  tags = var.tags 
}

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
