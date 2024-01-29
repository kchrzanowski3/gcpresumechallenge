locals {
  domain = "secnowski.com"
  region = "us-east-1"
  zone = "us-east1-a"
  terraform_org = "kylechrzanowski"
  terraform_workspace = "infrastructure"
}

variable "project" {
  default = "resume-challenge-kyle-3"
  type = string
}
