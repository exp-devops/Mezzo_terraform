terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"                                                                         # Ensures compatibility with Azure DevOps provider
    }
  }
}

# Retrieves the Azure DevOps project details
data "azuredevops_project" "CNB-project" {
  name = var.devopsprojectname
}

resource "azuredevops_build_definition" "pipeline" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "${var.project_name}-${var.project_environment}-pipeline"
  path       = "\\"  # Root folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"  
    #repo_id              = "meezo-kevin/mezzocicdtesting-terraform"
    repo_id               = "Mezzo-CityNational/testmezzocicd"
    branch_name           = "refs/heads/main"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.github_service_connection  # Connect to GitHub token
  }
/*
  variable_groups = [
    azuredevops_variable_group.aks-variable_group.id
  ]*/
}






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


