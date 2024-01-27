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
  project     = var.subscription
  region      = "us-east1"
  zone    =     "us-east1-a"

}

variable "subscription" {
  type = string
  default = "resume-challenge-kyle-3"
}

