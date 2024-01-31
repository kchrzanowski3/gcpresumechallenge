locals {
  roles = [
    "roles/resourcemanager.projectIamAdmin", # GitHub Actions identity
    "roles/editor", # allow to manage all resources
    "roles/storage.admin",
  ]
  github_repository_name = "kchrzanowski3/gcpresumechallenge" # e.g. yourname/yourrepo
}

data "google_project" "gcp_project" {
  project_id = var.project
}

##
## OIDC provider for ci/cd pipeline in github actions
##

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  project = var.project
  workload_identity_pool_id = "github-pool"
  display_name        = "Pool for GitHub Actions"
  description         = "Identity pool for authenticating GitHub Actions"
}

# Workload Identity Provider - GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project = var.project
  workload_identity_pool_id   = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name           = "GitHub OIDC Provider"
  description            = "Provider for GitHub OIDC"
  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.actor"       = "assertion.actor"
    "attribute.repository"  = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 
# Configure the service account that can do stuff for users
# 

resource "google_service_account" "my_service_account" {
  project = var.project
  account_id   = "github-actions-sa" 
  display_name = "Service Account for Github Actions"
  description  = "link to Workload Identity Pool used by GitHub Actions"
}

#attach it to the pool
resource "google_service_account_iam_member" "pool_member" {
  service_account_id = google_service_account.my_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${local.github_repository_name}"
}

#assign all the roles in the locals block above
resource "google_project_iam_member" "roles" {
  project = var.project
  for_each = {
    for role in local.roles : role => role
  }
  role   = each.value
  member = "serviceAccount:${google_service_account.my_service_account.email}"
}


##
## Outputs to put in the github actions yaml file
##

output "service_account_github_actions_email" {
  description = "Service Account used by GitHub Actions. Put in yaml file -> service_account:"
  value       = google_service_account.my_service_account.email
}

output "google_iam_workload_identity_pool_provider_github_name" {
  description = "Workload Identity Pool Provider ID. Put in yaml file -> workload_identity_provider:"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}