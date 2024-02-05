##
## Create dns entry for displaying the web page
##

# Add a record to the domain
resource "cloudflare_record" "at" {
  count = var.environment == "prod" ? 1 : 0
  
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = google_compute_global_address.https_public_ip.address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "www" {
  count = var.environment == "prod" ? 1 : 0
  
  zone_id = var.cloudflare_zone_id
  name    = "www"
  value   = google_compute_global_address.https_public_ip.address
  type    = "A"
  ttl     = 3600
}