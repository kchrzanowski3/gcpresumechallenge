#storage bucket
resource "google_storage_bucket" "static-site" {
  project = module.enabled_google_apis.project_id
  name          = "kyle-resume-site"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    #not_found_page   = "404.html"
  }
}

#makes bucket accessible by all
resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.static-site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

#upload index file
resource "google_storage_bucket_object" "webpage" {
  name   = "index.html"
  source = "../index.html"
  bucket = google_storage_bucket.static-site.name
}

#upload css file
resource "google_storage_bucket_object" "css" {
  name   = "style.css"
  source = "../style.css"
  bucket = google_storage_bucket.static-site.name
}

#substitute the api gateway link into the javascript file
resource "local_file" "script_file" {
  content = templatefile("${path.module}/scripts.js.tpl", {
    api_link = "https://${google_api_gateway_gateway.api_gw.default_hostname}/${local.api_path}"
  })

  filename = "${path.module}/scripts.js"
}

#upload scripts.js file
resource "google_storage_bucket_object" "script" {
  name   = "scripts.js"
  source = local_file.script_file.filename
  bucket = google_storage_bucket.static-site.name
}

