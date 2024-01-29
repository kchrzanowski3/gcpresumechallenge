locals {
  services = toset([
    # API Gateway APIs
    "apigateway.googleapis.com", #used for the API creation and management
    "servicecontrol.googleapis.com", #Provides admission control and telemetry reporting for services integrated with Service Infrastructure.
    "servicemanagement.googleapis.com", #Service Management allows service producers to publish their services on Google Cloud Platform
    "cloudfunctions.googleapis.com", #cloud functions api
    "cloudbuild.googleapis.com", #cloud function api

  ])
}


resource "google_project_service" "service" {
  for_each = local.services
  project  = var.project
  service  = each.value
}

