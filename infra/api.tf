##
## API Gateway construction
##

# api construction
resource "google_api_gateway_api" "api" {
  project = module.enabled_google_apis.project_id
  provider = google-beta
  api_id   = "kyle-resume-api"
}

# api config application
resource "google_api_gateway_api_config" "api_config" {
  project = module.enabled_google_apis.project_id
  provider = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "kyle-resume-api-config-${random_string.random_config.result}"

  openapi_documents {
    document {
      path     = local_file.rendered_openapi.filename
      contents = local.config_base64
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ local_file.rendered_openapi ]
}

#makes the config unique
resource "random_string" "random_config" {
  length           = 6
  special          = false
  numeric = false
  upper = false
}

# api gateway creation
resource "google_api_gateway_gateway" "api_gw" {
  project = module.enabled_google_apis.project_id
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "kyle-resume-api-gateway"
}

##
## dynamically create and load the openapi file
##

# Encode the file contents into Base64
locals {
  config_base64 = base64encode(local_file.rendered_openapi.content)
}

#dynamically inject variables into the openapi file 
resource "local_file" "rendered_openapi" {
  content = templatefile("${path.module}/visitor-counter-api-config.yaml.tpl", {
    project_name = module.enabled_google_apis.project_id
    region = local.region
    function_name = google_cloudfunctions_function.function.name
    api_path = local.api_path
  })

  filename = "${path.module}/visitor-counter-api-config.yaml"
}

##
## dynamically create and load the main function python file (main.py)
##

#dynamically inject variables into the cypress spec.cy.js test file 
resource "local_file" "rendered_python_function" {
  content = templatefile("${path.module}/main.py.tpl", {
    app_ip = var.environment == "prod" ? "https://${var.domain}" : "http://${google_compute_global_address.https_public_ip.address}"
  })

  filename = "${path.module}/api-function/main.py"
} 

##
## Cloud Function to update the db on the back end
##

# zip the file to upload it b/c function requires a zipped file
data "archive_file" "init" {
  type        = "zip"
  source_dir = "${path.module}/api-function"
  output_path = "${path.module}/api-function.zip"

  depends_on = [ local_file.rendered_python_function ]
}

# bucket to upload the zip to create a google function
resource "google_storage_bucket" "functions_bucket" {
  project = module.enabled_google_apis.project_id
  name     = "${var.project_title}-py_function-visitor-counter"
  location = "US"
  uniform_bucket_level_access = true
}

# upload the zip to the bucket
resource "google_storage_bucket_object" "function_python" {
  #forces a function rebuild every time the python file that defines the function changes
  name   = "sourcecode.${data.archive_file.init.output_md5}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.init.output_path
}

# create the google function
resource "google_cloudfunctions_function" "function" {
  project = module.enabled_google_apis.project_id
  name        = "resume-visitor-counter-function"
  description = "When someone visits the resume website, this function runs and increments the firestore (datastore) db entry"
  runtime     = "python39"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.function_python.name
  trigger_http          = true
  entry_point           = "hello_get"

}

#output the api url to test
output "api_ip" {
  value = google_api_gateway_gateway.api_gw.default_hostname
}

