terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

variable "GOOGLE_GHA_CREDS_PATH" {
  default = "/Users/kyle.chrzanowski/Downloads/strange-cycle-371319-b6cf49d2ce9d.json"
}

provider "google" {
  credentials = file(var.GOOGLE_GHA_CREDS_PATH)

  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

provider "google-beta" {
  credentials = file(var.GOOGLE_GHA_CREDS_PATH)
  project     = "strange-cycle-371319"
  region      = "us-east1"
  zone        = "us-east1-b"
}

//creates the storage bucket
resource "google_storage_bucket" "artifactbucket" {
  name                        = "artifactbucket"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

}
//makes everyone able to see the website / bucket
resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.artifactbucket.name
  role   = "roles/storage.objectViewer"
  member = "user:kyle.chrzanowski@gmail.com"
}

//add the website objects to the bucket - index.html
resource "google_storage_bucket_object" "testresultsfile" {
  name   = "testresults.txt"
  source = "../resume-architecture/testresults"
  bucket = google_storage_bucket.artifactbucket.name
}
