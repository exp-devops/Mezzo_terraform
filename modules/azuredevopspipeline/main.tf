terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}



data "azuredevops_project" "CNB-project" {
  name = var.azure_devops_project_name
}


resource "azuredevops_git_repository" "aks_repo" {
  project_id  = data.azuredevops_project.CNB-project.id
  name        = "${var.project_name}-${var.project_environment}-aks-azuredevops-git-repository"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository_file" "azure_pipeline_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "azure-pipelines.yml"  # Path in the repo
  content        = file("${path.module}/deploy/azure-pipelines.yml") # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding azure-pipeline.yml via Terraform"
}

resource "azuredevops_git_repository_file" "deployment_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "deployment.yml"  # Path in the repo
  content        = file("${path.module}/deploy/deployment.yml")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding deployment.yml via Terraform"
}
resource "azuredevops_git_repository_file" "service_yml" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "service.yml"  # Path in the repo
  content        = file("${path.module}/deploy/service.yml")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding service.yml via Terraform"
}
resource "azuredevops_git_repository_file" "Dockerfile" {
  repository_id  = azuredevops_git_repository.aks_repo.id  
  file           = "Dockerfile"  # Path in the repo
  content        = file("${path.module}/deploy/Dockerfile")  # Reads local file content
  branch         =  "refs/heads/master"
  commit_message = "Adding Dockerfile via Terraform"
}

/*
resource "null_resource" "aks_push_files" {
  depends_on = [azuredevops_git_repository.aks_repo]

  provisioner "local-exec" {
    command = <<EOT
      git clone ${azuredevops_git_repository.aks_repo.remote_url} repo
      rmdir /s /q repo || rm -rf repo
      cd repo
      cp "${path.module}/deploy/deployment.yml" deployment.yml
      cp "${path.module}/deploy/service.yml" service.yml
      cp "${path.module}/deploy/azure-pipelines.yml" azure-pipelines.yml
      cp "${path.module}/deploy/Dockerfile" Dockerfile
      git add .
      git commit -m "Added AKS deployment files"
      git push origin main
    EOT
  }
}
*/
/*
resource "null_resource" "aks_push_files" {
   depends_on = [azuredevops_git_repository.aks_repo]
  provisioner "local-exec" {
    command = <<EOT
      git clone ${azuredevops_git_repository.aks_repo.remote_url} repo
      cd repo
      echo '${cat("${path.module}/deploy/deployment.yml")}' > deploy/deployment.yml
      echo '${path.module}/deploy/service.yml' > deploy/service.yml
      echo '${path.module}/deploy/zure-pipeline.yml' > azure-pipelines.yml
      echo '${path.module}/deploy/Dockerfile' > Dockerfile
      git add .
      git commit -m "Added AKS deployment files"
      git push origin main
    EOT
  }
}
*/


resource "azuredevops_variable_group" "aks-variable_group" {
  project_id   = data.azuredevops_project.CNB-project.id
  name         = "Example Pipeline Variables"
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
    name   = "AKS_CLUSTER"
    value  = var.aks_cluster
  }
  variable{
    name  = "IMAGE_TAG"
    value = var.image_tag
  }
}

resource "azuredevops_build_definition" "example" {
  project_id = data.azuredevops_project.CNB-project.id
  name       = "Example Build Definition"
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
}


