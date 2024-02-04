##
## apis for cicd auth and github actions and stuff stuff
## 

# locals {
#   services = toset([
#     # MUST-HAVE for GitHub Actions setup
#     "iam.googleapis.com",                  # Identity and Access Management (IAM) API
#     "iamcredentials.googleapis.com",       # IAM Service Account Credentials API
#     "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
#     "sts.googleapis.com",  # Security Token Service API
#     "serviceusage.googleapis.com",                #Enables services that service consumers want to use on Google Cloud Platform, lists the available or enabled services, or disables services that service consumers no longer use.


#   ])
# }


# resource "google_project_service" "service" {
#   for_each = local.services
#   project  = var.project
#   service  = each.value
#   disable_dependent_services = true
#   #disable_on_destroy = false
# }

##
## Enabled APIs for the project where the OIDC idp provider is located
##

module "enabled_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  #version                     = "10.2.0"
  project_id =      var.project
  activate_apis               = [
    # MUST-HAVE for GitHub Actions setup
    "iam.googleapis.com",                  # Identity and Access Management (IAM) API
    "iamcredentials.googleapis.com",       # IAM Service Account Credentials API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "sts.googleapis.com",  # Security Token Service API
    "serviceusage.googleapis.com",                #Enables services that service consumers want to use on Google Cloud Platform, lists the available or enabled services, or disables services that service consumers no longer use.
    
    "cloudbilling.googleapis.com",    #used for creating new projects
  ]
  disable_services_on_destroy = false
}