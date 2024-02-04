##
## Create a folder structure that goes: 
##   
##      Environment  (e.g., Prod/Test)
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
resource "google_folder" "product_folder" {
  display_name = var.product
  parent       = "organizations/${ data.google_organization.org.org_id }"
}

#environment level folder
resource "google_folder" "environment_folder" {
  display_name = var.environment
  parent       = google_folder.product_folder.name
}

resource "google_project" "deploy_to_project" {
  name       = "${var.product}-${ var.environment }-${ random_string.project_name_suffix.result }"
  project_id = "${var.product}-${ var.environment }-${ random_string.project_name_suffix.result }"
  folder_id  = google_folder.environment_folder.id
  billing_account = "01259D-F0CA06-979A1E" #data.google_billing_account.acct.billing_account
}

resource "random_string" "project_name_suffix" {
  length           = 6
  special          = false
  numeric = false
  upper = false
}

 