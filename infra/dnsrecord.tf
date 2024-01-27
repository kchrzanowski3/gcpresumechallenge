/*


#The godaddy config was very verbose and thought every apply was a change so I turned it off for now 

variable "go_daddy_secret" {
    type = string
}
variable "go_daddy_key" {
    type = string
}

resource "godaddy_domain_record" "secnowski" {
  domain = var.domain
  #customer = "414897602"
  #addresses = [google_compute_global_address.https_public_ip.address]
  nameservers = ["ns59.domaincontrol.com", "ns60.domaincontrol.com"]

  record {
    name = "@"
    type = "A"
    data = google_compute_global_address.https_public_ip.address
    ttl = 3600
    #port = 443
  }

  record {
    name = "www"
    type = "A"
    data = google_compute_global_address.https_public_ip.address
    ttl = 3600
    #port = 443
  }


  #existing dns records below this line
  record {
    name = "autodiscover"
    type = "CNAME"
    data = "autodiscover.outlook.com"
    ttl = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl = 3600
  }

  record {
    name = "@"
    type = "MX"
    data = "secnowski-com.mail.protection.outlook.com"
    ttl = 3600
  }

  record {
    name = "@"
    type = "TXT"
    data = "MS=ms21031877"
    ttl = 3600
  }
  
  record {
    data = "v=spf1 include:spf.protection.outlook.com -all"
    name = "@"
    type = "TXT"
    ttl = 3600
    port = 0
    priority = 0
    weight = 0
  }

}*/