##
## Create a folder structure that goes: 
##
##      Authentication  
##          Project 
##

data "google_organization" "org" {
  domain = "kylenowski.com"
}

data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

# top level folder
resource "google_folder" "auth_folder" {
  display_name = "Authentication"
  parent       = "organizations/${ data.google_organization.org.org_id }"
}

resource "google_project" "gcp_project" {
  name       = var.project
  project_id = var.project
  folder_id  = google_folder.auth_folder.id
  billing_account = var.billing_account_id #data.google_billing_account.acct.billing_account
}

