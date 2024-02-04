

data "google_organization" "org" {
  domain = "kylenowski.com"
}

data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

resource "google_project" "deploy_to_project" {
  name       = var.project_title
  project_id = var.project_title
  folder_id  = data.google_folder.environment_folder.id
  billing_account = var.billing_account #data.google_billing_account.acct.billing_account
}

# test or prod folder
data "google_folder" "environment_folder" {
  #sets the folder to the prod folder or the test folder depending on what the environment is 
  folder = var.environment == "prod" ? "953495757565" : "663093161526" 
}

# resource "random_string" "project_name_suffix" {
#   length           = 6
#   special          = false
#   numeric = false
#   upper = false
# }
