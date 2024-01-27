#api for cicd auth and stuff
resource "google_project_service" "crm" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = false // Prevent disabling dependent APIs
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name        = "Pool for GitHub Actions"
  description         = "Identity pool for authenticating GitHub Actions"
}

# Workload Identity Provider - GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id   = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name           = "GitHub OIDC Provider"
  description            = "Provider for GitHub OIDC"
  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.actor"       = "assertion.actor"
    "attribute.repository"  = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    # allowed_audiences = [
    #   "projects/${var.subscription}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
    # ]
  }
}

# 
# Configure the service account that can do stuff for users
# 

resource "google_service_account" "my_service_account" {
  account_id   = "github-actions-sa" 
  display_name = "Service Account for Github Actions"
}

data "google_project" "gcp_project" {
  project_id = var.project
}

resource "google_service_account_iam_member" "pool_member" {
  service_account_id = google_service_account.my_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/projects/${data.google_project.gcp_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/${local.github_org_name}/${local.repository_name}"
}

##
## Service account permissions that is used by the idp provider
##



resource "google_project_iam_member" "full_admin" {
  project = var.project
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}
/*
resource "google_project_iam_member" "storage_admin" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "api_gateway_admin" {
  project = var.project
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "api_and_functions_admin" {
  project = var.project
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "cloud_run_admin" {
  project = var.project
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}
*/