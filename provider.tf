terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-tfstate-rg"
    storage_account_name = "mezzoterraformstate"
    container_name       = "tfstate"
    key                  = "mezzo-infra.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
/*terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-tfstate-rg"
    storage_account_name = "mezzoterraformstate"
    container_name       = "tfstate"
    key                  = "mezzo-infra.terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}*/


