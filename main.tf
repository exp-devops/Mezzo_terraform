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
