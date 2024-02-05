#enable apis for this
resource "google_project_service" "compute-engine-api" {
  project = module.enabled_google_apis.project_id
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}


##
## Application Load balancer
## 

#vpc 
resource "google_compute_network" "alb_network" {
  project = module.enabled_google_apis.project_id
  name                    = "my-alb-network"
  auto_create_subnetworks = false
}

#subnet in the vpc
resource "google_compute_subnetwork" "alb_subnet" {
  project = module.enabled_google_apis.project_id
  name          = "my-alb-subnet"
  network       = google_compute_network.alb_network.id
  region        = "us-east1"
  ip_cidr_range = "10.0.10.0/24"
}
 
#bucket as a back end target for the load balancer
resource "google_compute_backend_bucket" "image_backend" {
  project = module.enabled_google_apis.project_id
  name        = "backend-resume-bucket"
  description = "Points to Kyle Chrzanowski's resume bucket"
  bucket_name = google_storage_bucket.static-site.name
  enable_cdn  = true
}


## 
## Public IP for load balancers
##

#create a public ip
resource "google_compute_global_address" "https_public_ip" {
  project = module.enabled_google_apis.project_id
  name = "https-lb-global-address"
}


## 
## HTTP redirect Load balancer (if production environment)
##

#url map (route table)
resource "google_compute_url_map" "my_url_map" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name        = "http-redirect"
  description = "a basic HTTP URL map that reroutes HTTP traffic to HTTPS"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" // 301 redirect
    strip_query            = true
    https_redirect         = true // this is the magic
  }
}

#http proxy ties the url map to the load balancer
resource "google_compute_target_http_proxy" "my_http_proxy" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name    = "http-redirect"
  url_map = google_compute_url_map.my_url_map[count.index].self_link
}

#route traffic to the public ip and tie it to the proxy
resource "google_compute_global_forwarding_rule" "my_http_forwarding_rule" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name       = "http-redirect"
  target     = google_compute_target_http_proxy.my_http_proxy[count.index].self_link
  ip_address = google_compute_global_address.https_public_ip.address
  port_range = "80"
}

##
## HTTPS load balancer (if production environment)
##

#https proxy for the front end
resource "google_compute_target_https_proxy" "https" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name             = "https-proxy"
  url_map          = google_compute_url_map.https[count.index].id
  ssl_certificates = [google_compute_managed_ssl_certificate.my_certificate[count.index].id]

  depends_on = [ google_compute_managed_ssl_certificate.my_certificate ]
}

#create ssl cert
resource "google_compute_managed_ssl_certificate" "my_certificate" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name = google_project.deploy_to_project.name

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_url_map" "https" {
  count = var.environment == "prod" ? 1 : 0
  project = module.enabled_google_apis.project_id
  name            = "https-url-map"
  description     = "a description"
  default_service = google_compute_backend_bucket.image_backend.id
}

#route traffic to the public ip and tie it to the proxy
resource "google_compute_global_forwarding_rule" "my_https_forwarding_rule" {
  count = var.environment == "prod" ? 1 : 0
  
  project = module.enabled_google_apis.project_id
  name        = "my-https-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = google_compute_target_https_proxy.https[count.index].id
  ip_address  = google_compute_global_address.https_public_ip.address
}

##
## IF TEST ENVIRONMENT ONLY: HTTP Only Load Balancer 
##

#url map (route table)
resource "google_compute_url_map" "test_url_map" {
  count = var.environment == "test" ? 1 : 0
  project = module.enabled_google_apis.project_id

  name        = "http-test"
  description = "a basic HTTP URL map for use in test environments"
  default_service = google_compute_backend_bucket.image_backend.id
}

#http proxy ties the url map to the load balancer
resource "google_compute_target_http_proxy" "test_http_proxy" {
  count = var.environment == "test" ? 1 : 0
  project = module.enabled_google_apis.project_id

  name    = "http-test"
  url_map = google_compute_url_map.test_url_map[count.index].id
}

#route traffic to the public ip and tie it to the proxy
resource "google_compute_global_forwarding_rule" "test_http_forwarding_rule" {
  count = var.environment == "test" ? 1 : 0
  project = module.enabled_google_apis.project_id

  name       = "http-test"
  target     = google_compute_target_http_proxy.test_http_proxy[count.index].id
  ip_address = google_compute_global_address.https_public_ip.address
  port_range = "80"
  ip_protocol           = "TCP"

}


##
## Output for DNS entry
##

output "public_ip_address_for_DNS" {
  description = "public IP address of the application load balancer so it can be put into a DNS entry"
  value       =  google_compute_global_address.https_public_ip.address
}


