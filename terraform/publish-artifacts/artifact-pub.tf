terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

provider "google-beta" {
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

//upload the zipped up file to a bucket
resource "google_storage_bucket" "codebucket" {
  name     = "resume-function-code-bucket"
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "archive" {
  name   = "code.zip"
  bucket = google_storage_bucket.codebucket.name
  source = "../../terraform/build/built-code/code.zip"
}
