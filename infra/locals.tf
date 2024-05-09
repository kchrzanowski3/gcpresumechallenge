locals {
  region = "us-east1"
  zone = "us-east1a"
  api_path = "getvisitors"
}

variable "project_with_oidc_auth" {
  default = "resume-challenge-kyle-3"
  type = string
}

variable "product" {
  default = "resume-challenge"
  type = string
}

variable "environment" {
  default = "test"
  type = string
}

variable "domain" {
  default = "kylenowski.com"
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with"
  type        = string
  default     = "01851E-E66527-58EC61"
}

variable "cloudflare_api_key" {
  description = "The cloudflare api key used to create/edit records"
  type = string
}

variable "cloudflare_zone_id" {
  type = string
  default = "2ca1b94cd239ae09d0034d87c19739d8"
}

variable "project_title" {
  type = string
  default = "feature-testautomation-14" #"resume-challenge-prod-iwxabg"
}