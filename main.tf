# Modules for Resource Group
/*module "rg" {
  source               = "./modules/rg"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  tags                 = var.tags
}*/
# Modules for Virtual Network
module "vnet" {
  source               = "./modules/vnet"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  vnet_address_space   = var.vnet_address_space
  subnet_cidr          = var.subnet_cidr
  tags                 = var.tags 
}


# Modules for Key Vault
module "keyvault" {
  source               = "./modules/keyvault"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  tags                 = var.tags 
}
# Modules for MS SQL
module "mssql" {
  source               = "./modules/mssql"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  tags                 = var.tags 
  vault_id             = module.keyvault.vault_id
  max_size_gb          = var.max_size_gb
  sql_sku_name         = var.sql_sku_name
  vnet_id              = module.vnet.vnet_id
  privatesubnet1_id    = module.vnet.privatesubnet1_id
}

# Modules for ACR
module "acr" {
 source                = "./modules/acr"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  tags                 = var.tags 
  vnet_id              = module.vnet.vnet_id
  privatesubnet1_id    = module.vnet.privatesubnet1_id
}

# Modules for Static Web App
module "staticwebapps"{
  source               = "./modules/staticwebapps"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  tags                 = var.tags 
  staticwebapp_sku_tier= var.static_web_app_sku_tier

}

# Modules for Application Insights
module "applicationinsights"{
  source               = "./modules/applicationinsights"
  project_name         = var.project_name
  project_environment  = var.project_environment
  location             = var.location
  rg_mezzo             = var.resource_group_name
  tags                 = var.tags 
  workspace_sku        = var.workspace_sku
  retention_in_days    = var.retention_in_days

}

# Modules for Front Door
module "frontdoor"{
  source              = "./modules/frontdoor"
  project_name        = var.project_name
  project_environment = var.project_environment
  location            = var.location
  rg_mezzo            = var.resource_group_name
  tags                = var.tags 
 appgw_ip            = module.aks_appgw.appgw_ip
  static_web_app_url_admin    = module.staticwebapps.static_web_app_url_admin
  static_web_app_url_borrower = module.staticwebapps.static_web_app_url_borrower
  host_name_admin = var.host_name_admin
  host_name_borrower = var.host_name_borrower
  host_name_api = var.host_name_api
}
# Modules for Elastic Search
module "elasticsearch" {

  source             = "./modules/elasticsearch"
  project_name       = var.project_name
  project_environment= var.project_environment
  location           = var.location
  rg_mezzo           = var.resource_group_name
  tags               = var.tags
}

# Modules for Application gateway and AKS
module "aks_appgw" {
  source             = "./modules/aks_appgw"
  project_name       = var.project_name
  project_environment= var.project_environment
  location           = var.location
  rg_mezzo           = var.resource_group_name
  tags               = var.tags 
  nodepool1-maxcount = var.nodepool1-maxcount
  nodepool1-mincount = var.nodepool1-mincount
  acr_id             = module.acr.acr_id
  kubernetes_version = var.kubernetes_version
  vm_size            = var.vm_size
  aks_sku_tier       = var.aks_sku_tier
  /*tenant_id          = module.keyvault.keyvault_tenant_id
  subscription_id    = module.keyvault.keyvault_subscription_id*/
  publicsubnet1_id   = module.vnet.publicsubnet1_id
  publicsubnet2_id   = module.vnet.publicsubnet2_id
  rg_mezzo_id        = var.resource_group_id

}

# Modules for Azure DevOps
module "azuredevopspipeline"{
  source             = "./modules/azuredevopspipeline"
  project_name       = var.project_name
  project_environment= var.project_environment
  rg_mezzo           = var.resource_group_name
  acr_url            = module.acr.acr_url
  acr_admin_password = module.acr.acr_admin_password
  acr_admin_username = module.acr.acr_admin_username
  devopsprojectname  = var.azure_devops_project_name
  acr_name           = module.acr.acr_name
  aks_cluster        = module.aks_appgw.aks_cluster_name
  image_name         =  var.image_name
  image_tag          = var.image_tag
  github_service_connection =var.github_service_connection
  deployment_token_admin   = module.staticwebapps.static_web_app_deployment_token_admin
  deployment_token_borrower   = module.staticwebapps.static_web_app_deployment_token_borrower
  build_dir          = var.build_dir
  aks_api_url        = module.aks_appgw.aks_api_url
  aks_cluster_name   = module.aks_appgw.aks_cluster_name
  rg_mezzo_id        = var.resource_group_id
  subscription_name  =var.subscription_name
 sql_db_name        = module.mssql.sql_db_name
sql_private_endpoint = module.mssql.sql_private_endpoint
sql_username = module.mssql.sql_username
sql_password = module.mssql.sql_password
branch_admin = var.branch_admin
branch_borrower = var.branch_borrower
branch_api = var.branch_api
}