#terraform cloud connection
terraform {
  cloud {
    organization = "kylechrzanowski"

    workspaces {
      name = "oidc-provider"
    }
  }
}

provider "google" {
  project     = var.project
  region      = "us-east1"
  zone    =     "us-east1-a"

}


