terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.9"  # Ensure you use a supported version
    }
    
  }
  backend "azurerm" {
    
  }

  /*backend "azurerm" {
    #resource_group_name  = "terraform-tfstate-rg"
    #storage_account_name = "mezzoterraformstate"
    resource_group_name  = "CNB_DEV"
    storage_account_name = "mezzoterraformscript"
    container_name       = "tfstate"
    key                  = "mezzo-infra.terraform.tfstate"
  }*/
}

provider "azurerm" {
  features {}
  #skip_provider_registration = true

}
/*
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}
*/

provider "kubernetes" {
  host                   = module.aks_appgw.host
  client_certificate     = base64decode(module.aks_appgw.client_certificate)
  client_key             = base64decode(module.aks_appgw.client_key)
  cluster_ca_certificate = base64decode(module.aks_appgw.cluster_ca_certificate)
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/MezzoOrg"
  personal_access_token = var.azure_devops_pat
}
