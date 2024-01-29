#terraform cloud connection
terraform {
  cloud {
    organization = "kylechrzanowski"

    workspaces {
      name = "infrastructure"
    }
  }
}

terraform {
  required_providers {
    godaddy = {
      source  = "n3integration/godaddy"
      version = "~> 1.9.1" # Replace with the desired version
    }
  }
}


provider "google" {
  project = var.project
  region  = "us-east1"
  zone    = "us-east1-a"

}

#api gateway functions are in beta so have to use this
provider "google-beta" {
  project     = var.project
  region      = "us-east1"
  zone = "us-east1-a"
}

