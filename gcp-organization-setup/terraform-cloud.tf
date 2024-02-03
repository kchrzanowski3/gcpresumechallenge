#terraform cloud connection
terraform {
  cloud {
    organization = "kylechrzanowski"

    workspaces {
      #project = "${local.terraform_workspace}"
      name = "gcp-organization"
    }
  }
}

