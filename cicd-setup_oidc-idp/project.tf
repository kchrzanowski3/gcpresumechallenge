##
## Create a folder structure that goes: 
##
##      Authentication  
##          Project 
##

data "google_organization" "org" {
  domain = "kylenowski.com"
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
  billing_account = var.billing_account_id 
  
}


##
## Create a folder structure that goes: 
##  Product (Resume name)
##      Environment  (e.g., Prod/Test)
##          Projects - each pull request
##

# top level folder
resource "google_folder" "product_folder" {  
  display_name = var.product
  parent       = "organizations/${ data.google_organization.org.org_id }"
}

#environment level prod folder
resource "google_folder" "environment_folder" {
  display_name = "prod"
  parent       = google_folder.product_folder.name
}

#environment level test folder
resource "google_folder" "environment_folder" {
  display_name = "test"
  parent       = google_folder.product_folder.name
}

##
## roles to give the service account permissions to do all the actions stuff
##

locals {
  org_roles = [
    "roles/owner", 
    "roles/billing.admin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.projectCreator",    
  ]
}

resource "google_organization_iam_member" "organization" {
  org_id  = data.google_organization.org.org_id
  for_each = {
    for role in local.org_roles : role => role
  }
  role    = each.value
  member  = "serviceAccount:${ google_service_account.my_service_account.email }"
}

