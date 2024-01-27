#enable apis for this
resource "google_project_service" "compute-engine-api" {
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
  name                    = "my-alb-network"
  auto_create_subnetworks = false 
}

#subnet in the vpc
resource "google_compute_subnetwork" "alb_subnet" {
  name          = "my-alb-subnet"
  network       = google_compute_network.alb_network.id
  region        = "us-east1"
  ip_cidr_range = "10.0.10.0/24" 
}

#bucket as a back end target for the load balancer
resource "google_compute_backend_bucket" "image_backend" {
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
  name = "https-lb-global-address"
}


## 
## HTTP Load balancer
##

#url map (route table)
resource "google_compute_url_map" "my_url_map" {
  name        = "http-redirect"
  description = "a basic HTTP URL map that reroutes HTTP traffic to HTTPS"
  
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"  // 301 redirect
    strip_query            = true
    https_redirect         = true  // this is the magic
  }
}

#http proxy ties the url map to the load balancer
resource "google_compute_target_http_proxy" "my_http_proxy" {
  name    = "http-redirect"
  url_map = google_compute_url_map.my_url_map.self_link
}

#route traffic to the public ip and tie it to the proxy
resource "google_compute_global_forwarding_rule" "my_http_forwarding_rule" {
  name        = "http-redirect"
  target      = google_compute_target_http_proxy.my_http_proxy.self_link
  ip_address = google_compute_global_address.https_public_ip.address
  port_range  = "80"
}


##
## add https load balancer capability
##

#https proxy for the front end
resource "google_compute_target_https_proxy" "https" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [google_compute_managed_ssl_certificate.my_certificate.id]
}

#create ssl cert
resource "google_compute_managed_ssl_certificate" "my_certificate" {
  name = "my-ssl-certificate"

  managed {
    domains = [local.domain] 
  }
}

resource "google_compute_url_map" "https" {
  name        = "https-url-map"
  description = "a description"
  default_service = google_compute_backend_bucket.image_backend.id
}

#route traffic to the public ip and tie it to the proxy
resource "google_compute_global_forwarding_rule" "my_https_forwarding_rule" {
  name        = "my-https-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = google_compute_target_https_proxy.https.id 
  ip_address = google_compute_global_address.https_public_ip.address
}

##
## Output for DNS entry
##

output "public_ip_address_for_DNS" {
  description = "public IP address of the application load balancer so it can be put into a DNS entry"
  value       = google_compute_global_address.https_public_ip.address
}


