terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/andriylew29"
  personal_access_token = var.personalacctoken
  #set with env var as AZDO_PERSONAL_ACCESS_TOKEN

}

resource "azuredevops_project" "project" {
  name            = "alev-tf-pipeline"
  visibility      = "private"
  version_control = "Git"
  features = {
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "enabled"
    "artifacts"    = "enabled"
  }
}

resource "azuredevops_serviceendpoint_github" "serviceendpoint_alev_gh" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "Sample GithHub Personal Access Token"

  auth_personal {
    # personal_access_token set with AZDO_GITHUB_SERVICE_CONNECTION_PAT environment variable

  }
}

resource "azuredevops_build_definition" "build" {
  project_id = azuredevops_project.project.id
  name       = "Sample Build Definition"


  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "andriylew/azure-web2-priv"
    branch_name           = "main"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_alev_gh.id
  }

}
resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "owner-alev-terraform"
  description               = "Managed by Terraform"
  azurerm_subscription_name = "ownserv"
}

output "azureSubscription" {
  value = azuredevops_serviceendpoint_azurerm.endpointazure.id

}


