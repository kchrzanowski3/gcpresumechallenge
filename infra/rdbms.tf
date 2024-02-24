resource "google_sql_database_instance" "main" {
  #name             = "main-instance"
  database_version = "POSTGRES_15"
  region           = "us-east1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "MYSQL_8_0"
  }
  deletion_protection = false
}


