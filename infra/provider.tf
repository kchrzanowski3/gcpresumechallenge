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
      source = "n3integration/godaddy"
      version = "~> 1.9.1" # Replace with the desired version
    }
  }
}


provider "google" {
  project     = "resume-challenge-kyle-3"
  region      = "us-east1"
  zone    =     "us-east1-a"

}
 
# provider "godaddy" {
#   key    = var.go_daddy_key
#   secret = var.go_daddy_secret
# }


