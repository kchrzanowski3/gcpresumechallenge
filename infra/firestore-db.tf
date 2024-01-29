##
## Firestore in datastore mode
##

resource "google_firestore_database" "datastore_mode_database" {
  project                           = var.project
  name                              = "(default)"
  location_id                       = "nam5"
  type                              = "DATASTORE_MODE"
  concurrency_mode                  = "OPTIMISTIC"
  app_engine_integration_mode       = "DISABLED"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_DISABLED"
  delete_protection_state           = "DELETE_PROTECTION_DISABLED"
  deletion_policy                   = "DELETE"
}

# You can't create database entities (i.e. tables) in terraform. Create from the python cloud function



