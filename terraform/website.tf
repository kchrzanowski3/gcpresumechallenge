
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

# Run the script to get the environment variables of interest.
# This is a data source, so it will run at plan time.
data "external" "env" {
  program = ["${path.module}/env.sh"]

}

# Show the results of running the data source. This is a map of environment
# variable names to their values.
output "env" {
  value = data.external.env.result
}

# This outputs "bar"
output "foo" {
  value = data.external.env.result["foo"]
}



provider "google" {
  credentials = file(data.external.env.result["GOOGLE_GHA_CREDS_PATH"])
  //impersonate_service_account = "sa-githubpublish@strange-cycle-371319.iam.gserviceaccount.com"
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

provider "google-beta" {
  credentials = file(data.external.env.result["GOOGLE_GHA_CREDS_PATH"])
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}



//creates the storage bucket
resource "google_storage_bucket" "resumebucket" {
  name                        = "resumebucket"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
  }
}
//makes everyone able to see the website / bucket
resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.resumebucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

//add the website objects to the bucket - index.html
resource "google_storage_bucket_object" "indexfile" {
  name   = "index.html"
  source = "../Front End Files/index.html"
  bucket = google_storage_bucket.resumebucket.name
}
//add the website objects to the bucket - sripts.js
resource "google_storage_bucket_object" "scriptsfile" {
  name   = "scripts.js"
  source = "../Front End Files/scripts.js"
  bucket = google_storage_bucket.resumebucket.name
}
//add the website objects to the bucket - style.css
resource "google_storage_bucket_object" "cssfile" {
  name   = "style.css"
  source = "../Front End Files/style.css"
  bucket = google_storage_bucket.resumebucket.name
}


//api gateway construction
resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id = "resumeapi2"
}

//api config creation
resource "google_api_gateway_api_config" "api_config" {
  provider = google-beta
  api = google_api_gateway_api.api.api_id
  api_config_id = "kyleapiconfig"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("../Back End Files/APIGateway/openapi2-functions.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

//api gateway gateway creation
resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "apigateway10"
}



//now do google functions
//have to upload the code to a bucket
resource "google_storage_bucket" "codebucket" {
  name     = "resume-function-code-bucket"
  location = "US"
  uniform_bucket_level_access = true

}

data "archive_file" "googlerunzip" {
  type = "zip"
  output_path = "../Back End Files/gcpfunction/code.zip"
  source_dir = "../Back End Files/gcpfunction/"
}

resource "google_storage_bucket_object" "archive" {
  name   = "code.zip"
  bucket = google_storage_bucket.codebucket.name
  source = data.archive_file.googlerunzip.output_path
}


resource "google_cloudfunctions_function" "function" {
  name        = "function-2"
  description = "function that increments a counter by 1 in a database and returns the new value"
  runtime     = "python310"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.codebucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "hello_get"
}