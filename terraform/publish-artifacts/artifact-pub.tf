terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  cloud {
    organization = "kylechrzanowski"

    workspaces {
      name = "gcp-resume-build"
    }
  }
}

terraform {

}

provider "google" {
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

//create the bucket for code to be uploaded to
resource "google_storage_bucket" "codebucket" {
  name     = "resume-function-code-bucket"
  location = "US"
  uniform_bucket_level_access = true
}
