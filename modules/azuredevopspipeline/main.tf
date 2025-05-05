terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"                                                                         # Ensures compatibility with Azure DevOps provider
    }
  }
}
data "azurerm_client_config" "current" {

}


# Retrieves the Azure DevOps project details
data "azuredevops_project" "CNB-project" {
  name = var.devopsprojectname
}
# service connection for ACR
resource "azuredevops_serviceendpoint_dockerregistry" "acr_service_connection" {
  project_id            = data.azuredevops_project.CNB-project.id
  service_endpoint_name = "${var.project_name}-${var.project_environment}-acr-service-connection"
  docker_registry       = var.acr_url
  docker_username       = var.acr_admin_username
  docker_password       = var.acr_admin_password
  registry_type         = "Others" # "ACR" is only supported if using Managed Identity or Azure Resource Manager
  description = "Service connection to mezzodevprojectacr"
 
}
# service connection permission for ACR
resource "azuredevops_pipeline_authorization" "acr_service_connection_permission" {
  project_id  = data.azuredevops_project.CNB-project.id                      # The ID of the Azure DevOps project
  resource_id = azuredevops_serviceendpoint_dockerregistry.acr_service_connection.id  # The ID of the Docker registry service connection
  type        = "endpoint"                                          # The type of resource being authorized, "endpoint" is for service connections
}

resource "azuredevops_serviceendpoint_kubernetes" "aks_service_connection" {
  project_id            = data.azuredevops_project.CNB-project.id
  service_endpoint_name = "${var.project_name}-${var.project_environment}-aks-service-connection"
  apiserver_url         = "https://${var.aks_api_url}"
  authorization_type    = "AzureSubscription"

  azure_subscription {
    subscription_id   = data.azurerm_client_config.current.subscription_id
    subscription_name = var.subscription_name
    tenant_id         = data.azurerm_client_config.current.tenant_id   
    resourcegroup_id  =  var.rg_mezzo
    cluster_name      = var.aks_cluster_name
    namespace         = "${var.project_name}-${var.project_environment}"

  }
}
resource "azuredevops_pipeline_authorization" "aks_service_connection_permission" {
  project_id  = data.azuredevops_project.CNB-project.id                      # The ID of the Azure DevOps project
  resource_id = azuredevops_serviceendpoint_kubernetes.aks_service_connection.id  # The ID of the Docker registry service connection
  type        = "endpoint"                                          # The type of resource being authorized, "endpoint" is for service connections
}


#Azure Devops Pipeline for API
resource "azuredevops_build_definition" "aks_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-aks-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    repo_id               = "Mezzo-CityNational/core-service"
    branch_name           = "refs/heads/${var.branch_api}"
    yml_path              = "azure-pipeline.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
  }
  variable_groups = [
    azuredevops_variable_group.aks_variable_group.id
  ]
}
# Azure Devops variable group for API
resource "azuredevops_variable_group" "aks_variable_group" {
  project_id   = data.azuredevops_project.CNB-project.id
  name         = "${var.project_name}-${var.project_environment}-aks-variable-group"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "ACR_NAME"
    value = var.acr_name
  }

  variable {
    name  = "IMAGE_NAME"
    value = var.image_name
  }

  variable {
    name  = "RESOURCE_GROUP"
    value = var.rg_mezzo
  }

  variable {
    name   = "AKS_CLUSTER_NAME"
    value  = var.aks_cluster
  }
  variable{
    name  = "IMAGE_TAG"
    value = var.image_tag
  }
 
  variable {
    name  = "ACR-SERVICE-CONNECTION"
    value = "${var.project_name}-${var.project_environment}-acr-service-connection"
  }
  variable {
    name  = "AKS-SERVICE-CONNECTION"
    value = "${var.project_name}-${var.project_environment}-aks-service-connection"
  }
  variable {
    name = "NAMESPACE"
    value = "${var.project_name}-${var.project_environment}"
  }
}

#Azure Devops Pipeline for Admin static app.
  resource "azuredevops_build_definition" "admin_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-admin-static-webapps-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    repo_id               = "Mezzo-CityNational/admin-portal"
    branch_name           = "refs/heads/${var.branch_admin}"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
    
  }
   variable_groups = [
    azuredevops_variable_group.admin_variable_group.id
  ]
  }
  # Azure Devops variable group for Admin
  resource "azuredevops_variable_group" "admin_variable_group" {
  project_id   = data.azuredevops_project.CNB-project.id
  name         = "${var.project_name}-${var.project_environment}-admin-static-webaaps-variable-group"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "build_dir"
    value = var.build_dir
  }
   variable {
    name  = "deployment_token"
    value = var.deployment_token_admin
  }  
  variable {
    name  = "PROJECT_NAME"
    value = var.project_name
  }
  variable {
    name  = "PROJECT_ENVIRONMENT"
    value = var.project_environment
  }

}
# Azure Devops pipeline for borrower static app.
 resource "azuredevops_build_definition" "borrower_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-borrower-static-webapps-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"     
    repo_id               = "Mezzo-CityNational/borrower-portal"
    branch_name           = "refs/heads/${var.branch_borrower}"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
    
  }
   variable_groups = [
    azuredevops_variable_group.borrower_variable_group.id
  ]
  }
  # Azure Devops variable group for borrower
  resource "azuredevops_variable_group" "borrower_variable_group" {
  project_id   = data.azuredevops_project.CNB-project.id
  name         = "${var.project_name}-${var.project_environment}-borrower-static-webaaps-variable-group"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "build_dir"
    value = var.build_dir
  }
   variable {
    name  = "deployment_token"
    value = var.deployment_token_borrower
  } 
  variable {
    name  = "PROJECT_NAME"
    value = var.project_name
  }
  variable {
    name  = "PROJECT_ENVIRONMENT"
    value = var.project_environment
  } 

}





