package terraform.gcp.gcs_public_access

# Define sets of public principals and roles that grant public read access or more
public_principals := {"allUsers", "allAuthenticatedUsers"}

# Roles that, when combined with public principals, make objects in a bucket public.
# This list can be expanded based on your organization's definition of "too permissive."
public_viewer_roles := {
    "roles/storage.objectViewer",
    "roles/storage.legacyObjectReader",
    "roles/storage.legacyBucketReader"
    # Potentially add roles/storage.admin or roles/storage.legacyBucketOwner if any public grant is disallowed
}

# Helper to check if a resource action is a create or update (i.e., not a delete-only action)
is_create_or_update(actions) {
    actions[_] != "delete" # True if any action is not "delete"
} else = false { # Default to false if only "delete" or empty (though plan should have action)
    true
}
# A simpler way, often sufficient: check if 'change.after' exists.
# If change.after is null, it's a delete.
resource_not_deleted(change) {
    change.after != null
}


# Deny if a 'google_storage_bucket_iam_member' makes a bucket public
deny[msg] {
    resource_change := input.resource_changes[_] # Iterate through each resource change
    resource_change.type == "google_storage_bucket_iam_member"
    resource_not_deleted(resource_change.change) # Ensure it's not just being deleted

    config := resource_change.change.after # Get the configuration after the change
    config.role # Ensure role attribute exists
    config.member # Ensure member attribute exists
    config.bucket # Ensure bucket attribute exists

    public_viewer_roles[config.role]        # Check if the role is a public viewer role
    public_principals[config.member]        # Check if the member is a public principal

    msg := sprintf(
        "Public GCS bucket access identified via google_storage_bucket_iam_member: Bucket '%s' grants role '%s' to '%s' in resource '%s'.",
        [config.bucket, config.role, config.member, resource_change.address]
    )
}

# Deny if a 'google_storage_bucket_iam_binding' makes a bucket public
deny[msg] {
    resource_change := input.resource_changes[_] # Iterate through each resource change
    resource_change.type == "google_storage_bucket_iam_binding"
    resource_not_deleted(resource_change.change) # Ensure it's not just being deleted

    config := resource_change.change.after # Get the configuration after the change
    config.role # Ensure role attribute exists
    config.members # Ensure members attribute exists
    config.bucket # Ensure bucket attribute exists

    public_viewer_roles[config.role] # Check if the role is a public viewer role
    assigned_member := config.members[_] # Iterate through members in the binding
    public_principals[assigned_member]   # Check if any assigned member is a public principal

    msg := sprintf(
        "Public GCS bucket access identified via google_storage_bucket_iam_binding: Bucket '%s' grants role '%s' to public principal '%s' (among others) in resource '%s'.",
        [config.bucket, config.role, assigned_member, resource_change.address]
    )
}

