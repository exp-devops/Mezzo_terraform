# Define the Terraform settings, including the required version and providers.
terraform {
  required_version   = ">= 1.3.0"  

  required_providers {
    # Define the AzureRM provider for managing Azure resources.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"  
    }

    # Define the Azure DevOps provider for managing DevOps resources.
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.9"  
    }
  }

  # Define the remote backend for storing Terraform state in Azure.
  backend "azurerm" {
    
  }
}

# Configure the AzureRM provider with required features.
provider "azurerm" {
  features {
    
  }
  skip_provider_registration = true
}

# Configure the Kubernetes provider to interact with the AKS cluster.
provider "kubernetes" {
  host                   = module.aks_appgw.host
  client_certificate     = base64decode(module.aks_appgw.client_certificate)
  client_key             = base64decode(module.aks_appgw.client_key)
  cluster_ca_certificate = base64decode(module.aks_appgw.cluster_ca_certificate)
}

# Configure the Azure DevOps provider with authentication details.
provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/MezzoOrg" 
  personal_access_token = var.azure_devops_pat 
}
