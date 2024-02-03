module "enabled_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  #version                     = "10.2.0"
  project_id =      google_project.deploy_to_project.project_id
  activate_apis               = [
    "apigateway.googleapis.com", #used for the API creation and management
    "servicecontrol.googleapis.com", #Provides admission control and telemetry reporting for services integrated with Service Infrastructure.
    "servicemanagement.googleapis.com", #Service Management allows service producers to publish their services on Google Cloud Platform
    "cloudfunctions.googleapis.com", #cloud functions api
    "cloudbuild.googleapis.com", #cloud function api
    "compute.googleapis.com",
    "firestore.googleapis.com",  #firestore api
    "datastore.googleapis.com"    #datastore api for the function storing database entries 
  ]
  disable_services_on_destroy = false
}
