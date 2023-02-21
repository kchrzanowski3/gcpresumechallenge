terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
  cloud {
    organization = "kylechrzanowski"

    workspaces {
      name = "gcp-resume-publish-deploy"
    }
  }
}

provider "google" {
  project = "strange-cycle-371319"
  region  = "us-east1"
  zone    = "us-east1-b"
}

provider "google-beta" {
  project = "strange-cycle-371319"
  region  = "us-east1"
  zone    = "us-east1-b"
}




// the project
resource "google_project" "my_project" {
  name            = "Resume Challenge"
  project_id      = "strange-cycle-371319"
  billing_account = "01C1E9-56FA78-90F2BA"
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



//now do google functions
//have to upload the code to a bucket
resource "google_cloudfunctions_function" "function" {
  name        = "function-2"
  description = "function that increments a counter by 1 in a database and returns the new value"
  runtime     = "python310"

  available_memory_mb   = 128
  source_archive_bucket = "resume-function-code-bucket"
  source_archive_object = "code.zip"
  trigger_http          = true
  entry_point           = "hello_get"
}

resource "google_project_service" "firestore" {
  provider = google-beta

  service = "firestore.googleapis.com"
}

resource "google_firestore_database" "datastore_mode_database" {
  provider = google-beta

  name = "(default)"

  location_id = "us-east1"
  type        = "DATASTORE_MODE"

  depends_on = [google_project_service.firestore]
}

# reserved IP address
resource "google_compute_global_address" "default" {
  provider = google-beta
  name     = "resumeip"
}

//create the https load balancer
resource "google_compute_target_https_proxy" "default" {
  name             = "resumelb2-target-proxy"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "cert3"
  managed {
    domains = ["kylechrzanowski.com", "www.kylechrzanowski.com"]
  }
}

resource "google_compute_url_map" "https" {
  name        = "resumelb2"
  description = "the https load balancer that services https traffic from the static ip"

  default_service = google_compute_backend_bucket.bucket_backend.id

  host_rule {
    hosts        = ["kylechrzanowski.com", "www.kylechrzanowski.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.bucket_backend.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.bucket_backend.id
    }
  }
}

resource "google_compute_url_map" "http" {
  name            = "newloadbalancer-redirect"
  description = "Automatically generated HTTP to HTTPS redirect for the newloadbalancer forwarding rule"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_backend_bucket" "bucket_backend" {
  name             = "resumebackend"
  description      = "Contains kyle's resume site"
  bucket_name      = google_storage_bucket.resumebucket.name
  enable_cdn       = true
  compression_mode = "DISABLED"
}

//create the http load balancer that redirects to https
resource "google_compute_target_http_proxy" "default" {
  name = "newloadbalancer-target-proxy"
  url_map = google_compute_url_map.http.id
}

