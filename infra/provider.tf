#terraform cloud connection
terraform {
  cloud {
    organization = "kylechrzanowski"
    workspaces {
      project = "gcpresumechallenge"
      #name = "infrastructure-test"
    }
  } 

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.41.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}

provider "google" {
  project = var.project_with_oidc_auth
  region  = "us-east1"
  zone    = "us-east1-a"
}

#api gateway functions are in beta so have to use this
provider "google-beta" {
  project     = var.project_with_oidc_auth
  region      = "us-east1"
  zone = "us-east1-a"
}

