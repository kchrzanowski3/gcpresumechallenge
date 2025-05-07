package terraform.gcp.gcs_public_access

# This policy uses standard OPA Rego syntax ("v0") to check for public GCS buckets
# in a Terraform plan JSON output, with an additional check for an approval label.

# Define sets of public principals and roles that grant public read access or more
public_principals := {"allUsers", "allAuthenticatedUsers"}

# Roles that, when combined with public principals, make objects in a bucket public.
public_viewer_roles := {
	"roles/storage.objectViewer",
	"roles/storage.legacyObjectReader",
	"roles/storage.legacyBucketReader"
	# Potentially add roles/storage.admin or roles/storage.legacyBucketOwner if any public grant is disallowed
}

# Helper rule to check if a resource is not being deleted.
# Standard Rego: no 'if' keyword at the start of the rule body.
resource_not_deleted(change) {
	change.after != null # True if 'change.after' exists (i.e., not a delete-only action)
}

# Helper function to check if the bucket is approved for public consumption via a label.
# Standard Rego: no 'if' keyword at the start of the rule body.
approved_for_public_consumption(config) {
    # Check if the 'labels' field exists and then if the specific label is set to "true".
    # Accessing nested fields like config.labels.approved_for_public_consumption
    # will result in 'undefined' if any part of the path doesn't exist,
    # causing this rule to not be satisfied (which is the desired behavior if the label isn't there).
	config.labels.approved_for_public_consumption == "true"
}

# Deny if a 'google_storage_bucket_iam_member' makes a bucket public,
# only if it does NOT have the 'approved_for_public_consumption' label.
# Standard Rego: partial set rule syntax 'deny[msg] { ... }'.
deny[msg] {
	resource_change := input.resource_changes[_] # Iterate through each resource change
	resource_change.type == "google_storage_bucket_iam_member"
	resource_not_deleted(resource_change.change) # Ensure it's not just being deleted

	config := resource_change.change.after # Get the configuration after the change
	
    # Ensure essential attributes exist for the IAM member resource.
    # If any of these are missing, the rule won't be satisfied for this resource_change.
	config.role
	config.member
	config.bucket

	# Check if the role is a public viewer role and the member is a public principal.
	public_viewer_roles[config.role]
	public_principals[config.member]

	# CRUCIAL CHECK: Ensure the bucket does NOT have the approved tag.
    # The 'not' keyword negates the result of the 'approved_for_public_consumption' rule.
	not approved_for_public_consumption(config)

    # If all conditions above are met, generate the violation message.
	msg := sprintf(
		"Public GCS bucket access identified via google_storage_bucket_iam_member: Bucket '%s' grants role '%s' to '%s' in resource '%s' and is NOT approved for public consumption via label.",
		[config.bucket, config.role, config.member, resource_change.address]
	)
}

