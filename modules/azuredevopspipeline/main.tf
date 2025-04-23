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
resource "azuredevops_serviceendpoint_dockerregistry" "acr_service_connection" {
  project_id            = data.azuredevops_project.CNB-project.id
  service_endpoint_name = "${var.project_name}-${var.project_environment}-acr-service-connection"
  docker_registry       = var.acr_url
  docker_username       = var.acr_admin_username
  docker_password       = var.acr_admin_password
  registry_type         = "Others" # "ACR" is only supported if using Managed Identity or Azure Resource Manager
  description = "Service connection to mezzodevprojectacr"
 
}
resource "azuredevops_pipeline_authorization" "acr_service_connection_permission" {
  project_id  = data.azuredevops_project.CNB-project.id                      # The ID of the Azure DevOps project
  resource_id = azuredevops_serviceendpoint_dockerregistry.acr_service_connection.id  # The ID of the Docker registry service connection
  type        = "endpoint"                                          # The type of resource being authorized, "endpoint" is for service connections
}/*
resource "azuredevops_serviceendpoint_azurerm" "aks_connection" {
  project_id            = data.azuredevops_project.CNB-project.id
  service_endpoint_name = "${var.project_name}-${var.project_environment}-aks-connection"
  description           = "AzureRM connection for AKS (no service principal)"

  azurerm_spn_tenantid       = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id    = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name  = var.subscription_name
}
resource "azuredevops_pipeline_authorization" "authorize_aks" {
  project_id  = data.azuredevops_project.CNB-project.id
  resource_id = azuredevops_serviceendpoint_azurerm.aks_connection.id
  type        = "endpoint"
}*/
/*
resource "azuredevops_serviceendpoint_kubernetes" "aks_service_connection" {
  project_id            = data.azuredevops_project.CNB-project.id    
  service_endpoint_name = "dev"
  apiserver_url         = var.aks_api_url # Automatically derived when using Azure Subscription
  authorization_type    = "AzureSubscription"
  azure_subscription {
    subscription_id   = data.azurerm_client_config.current.subscription_id
    subscription_name = "cnb_dev"
    tenant_id         = data.azurerm_client_config.current.tenant_id  
    resourcegroup_id = var.rg_mezzo_id
    cluster_name      = var.aks_cluster_name
    namespace         = "default"
  }
  description = "K8s service connection to mezzo-dev-aks-cluster"
}
resource "azuredevops_pipeline_authorization" "aks_service_connection_permission" {
  project_id  = data.azuredevops_project.CNB-project.id                      # The ID of the Azure DevOps project
  resource_id = azuredevops_serviceendpoint_kubernetes.aks_service_connection.id  # The ID of the Docker registry service connection
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
    resourcegroup_id =  var.rg_mezzo_id
    cluster_name      = var.aks_cluster_name
  }
}
resource "azuredevops_pipeline_authorization" "aks_service_connection_permission" {
  project_id  = data.azuredevops_project.CNB-project.id                      # The ID of the Azure DevOps project
  resource_id = azuredevops_serviceendpoint_kubernetes.aks_service_connection.id  # The ID of the Docker registry service connection
  type        = "endpoint"                                          # The type of resource being authorized, "endpoint" is for service connections
}*/



#Azure Devops Pipeline for Static App
resource "azuredevops_build_definition" "aks_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-aks-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    #repo_id              = "meezo-kevin/mezzocicdtesting-terraform"
    repo_id               = "Mezzo-CityNational/core-service"
    branch_name           = "refs/heads/${var.branch_api}"
    yml_path              = "azure-pipeline.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
  }
  variable_groups = [
    azuredevops_variable_group.aks_variable_group.id
  ]
}
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
  /*
  variable {
    name  = "ConnectionStrings__DbConnection"
    secret_value = "Data Source= ${var.sql_private_endpoint};Initial Catalog=${var.sql_db_name} ;Integrated Security =False; UID=${var.sql_username}; Password=${var.sql_password};MultipleActiveResultSets=true"
    is_secret    = true
  }*/
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


  resource "azuredevops_build_definition" "admin_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-admin-static-webapps-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    #repo_id              = "meezo-kevin/mezzocicdtesting-terraform"
    repo_id               = "Mezzo-CityNational/admin-portal"
    branch_name           = "refs/heads/${var.branch_admin}"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
    
  }
   variable_groups = [
    azuredevops_variable_group.admin_variable_group.id
  ]
  }
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

 resource "azuredevops_build_definition" "borrower_pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-borrower-static-webapps-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    #repo_id              = "meezo-kevin/mezzocicdtesting-terraform"
    repo_id               = "Mezzo-CityNational/borrower-portal"
    branch_name           = "refs/heads/${var.branch_borrower}"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
    
  }
   variable_groups = [
    azuredevops_variable_group.borrower_variable_group.id
  ]
  }
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

}/*
resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "${var.project_name}-${var.project_environment}-sql-secret"
    namespace = "${var.project_name}-${var.project_environment}"
  }

  data = {
    connection-string = "Data Source= ${var.sql-server-name}.privatelink.database.windows.net;Initial Catalog=${var.sql_db_name} ;Integrated Security =False; UID=${var.sql_username}; Password=${var.sql_password};MultipleActiveResultSets=true;"
  }

  type = "Opaque"
}*/





/*
/*
  variable_groups = [
    azuredevops_variable_group.aks-variable_group.id
  ]*/







/*
# Azure DevOps Git repository for AKS deployment files
resource "azuredevops_git_repository" "aks_repo" {
  project_id  = data.azuredevops_project.CNB-project.id
  name        = "${var.project_name}-${var.project_environment}-aks-azuredevops-git-repository"

# Initializes the repository with an empty structure
  initialization { 
    init_type = "Clean"
  }
}

# Adds an Azure Pipelines YAML file to the repository for CI/CD automation
resource "azuredevops_git_repository_file" "azure_pipeline_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "azure-pipelines.yml"  # Path in the repo
  content        = file("${path.module}/deploy/azure-pipelines.yml") # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding azure-pipeline.yml via Terraform"
}

# Adds a Kubernetes Deployment YAML file to the repository
resource "azuredevops_git_repository_file" "deployment_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "k8s/deployment.yml"  # Path in the repo
  content        = file("${path.module}/deploy/deployment.yml")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding deployment.yml via Terraform"
}

# Adds a Kubernetes Service YAML file to the repository
resource "azuredevops_git_repository_file" "service_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "k8s/service.yaml"  # Path in the repo
  content        = file("${path.module}/deploy/service.yml")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding service.yml via Terraform"
}

# Adds a Dockerfile to the repository for building container images
resource "azuredevops_git_repository_file" "Dockerfile" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "Dockerfile"  # Path in the repo
  content        = file("${path.module}/deploy/Dockerfile")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding Dockerfile via Terraform"
}

# Creates an Azure DevOps Variable Group to store environment-specific variables
resource "azuredevops_variable_group" "aks-variable_group" {
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
}

# Defines a CI/CD pipeline in Azure DevOps using the pipeline YAML file
resource "azuredevops_build_definition" "pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-pipeline"
  path       = "\\"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.aks_repo.id  
    branch_name = "refs/heads/master"
    yml_path    = "azure-pipelines.yml"
  }
  variable_groups = [
    azuredevops_variable_group.aks-variable_group.id
  ]
}*/
/*
resource "azuredevops_git_repository" "tf_imported_repo" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}--aks-azuredevops-git-repository"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/exp-devops/Mezzo_ci-cd_testing.git"
  }
}*/


