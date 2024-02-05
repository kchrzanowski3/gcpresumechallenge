##
## Cypress production test file
##

#dynamically inject variables into the cypress spec.cy.js test file 
resource "local_file" "rendered_cypress_test" {
  content = templatefile("${path.module}/cypress-test-template.cy.js.tpl", {
    website_address = var.environment == "prod" ? "https://${var.domain}" : "http://${google_compute_global_address.https_public_ip.address}"  #tests an ip or the actual domain depending on prod or not
    api_address = google_api_gateway_gateway.api_gw.default_hostname
    api_path = local.api_path
  })

  filename = "../cypress/e2e/spec.cy.js"
} 