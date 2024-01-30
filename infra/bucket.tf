

#storage bucket
resource "google_storage_bucket" "static-site" {
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

#upload scripts.js file
resource "google_storage_bucket_object" "script" {
  name   = "scripts.js"
  source = "../scripts.js"
  bucket = google_storage_bucket.static-site.name
}

