##
## API Gateway construction
##

//api gateway construction
resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "resumeapi2"
}

//get the base64 encoded version of the config file so it can be included in the api config
data "google_storage_bucket_object_content" "configfile" {
  name   = "openapi2-functions.yaml"
  bucket = "resume-function-code-bucket"
}

//api config creation
resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "kyleapiconfig"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = base64encode(data.google_storage_bucket_object_content.configfile.content)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

//api gateway gateway creation
resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "apigateway10"
}