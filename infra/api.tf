##
## API Gateway construction
##

# api construction
resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "kyle-resume-api"
}

# api config application
resource "google_api_gateway_api_config" "api_config" {
  provider = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "kyle-resume-api-config-${random_string.random_config.result}"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = filebase64("visitor-counter-api-config.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "random_string" "random_config" {
  length           = 6
  special          = false
  numeric = false
  upper = false
  #keepers = sha1(join("", [for f in fileset(path.cwd, "*"): filesha1("${path.cwd}/${f}")]))
  #override_special = ""
}

# api gateway creation
resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "kyle-resume-api-gateway"
}

##
## Cloud Function to update the db on the back end
##

# zip the file to upload it b/c function requires a zipped file
data "archive_file" "init" {
  type        = "zip"
  source_dir = "api-function"
  output_path = "${path.module}/api-function.zip"
}

# bucket to upload the zip to create a google function
resource "google_storage_bucket" "functions_bucket" {
  name     = "py_function-visitor-counter"
  location = "US"
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

