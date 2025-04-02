
data "azuredevops_project" "CNB-project" {
  name = var.azure_devops_project_name
}


resource "azuredevops_git_repository" "aks_repo" {
  project_id  = data.azuredevops_project.CBN-project.id
  name        = "${var.project_name}-${var.project_environment}-aks-azuredevops-git-repository"

  initialization {
    init_type = "Clean"
  }
}


resource "null_resource" "aks_push_files" {
  provisioner "local-exec" {
    command = <<EOT
      git clone $(azuredevops_git_repository.aks_repo.remote_url) repo
      cd repo
      echo '${file("deploy/deployment.yml")}' > deploy/deployment.yml
      echo '${file("deploy/service.yml")}' > deploy/service.yml
      echo '${file("azure-pipelines.yml")}' > azure-pipelines.yml
      echo '${file("Dockerfile")}' > Dockerfile
      git add .
      git commit -m "Added AKS deployment files"
      git push origin main
    EOT
  }
}


resource "azuredevops_build_definition" "aks_pipeline" {
  project_id = data.azuredevops_project.project_id
  name       = "${var.project_name}-${var.project_environment}-aks-pipeline"
  path       = "\\"

  repository {
    repo_type    = "TfsGit"
    repo_id      = data.azuredevops_git_repository.aks_repo.id
    branch_name  = var.branch
    yml_path     = "azure-pipelines.yml"
  }

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
    secret = false  # Set to true if it’s a sensitive variable
  }
  variable{
    name  = "IMAGE_TAG"
    value = var.image_tag
  }
}
