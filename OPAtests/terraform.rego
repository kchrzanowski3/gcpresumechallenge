package terraform.gcp.gcs_public_access

# This policy is written to conform to a specific "rego.v1" syntax requiring:
# 1. 'if' keyword before the rule body for single-value rules.
# 2. 'rule_name contains value if condition' for multi-value rules.

# Define sets of public principals and roles that grant public read access or more.
# Standard set definitions are assumed to be compatible.
public_principals := {"allUsers", "allAuthenticatedUsers"}

public_viewer_roles := {
    "roles/storage.objectViewer",
    "roles/storage.legacyObjectReader",
    "roles/storage.legacyBucketReader"
    # You can expand this list if other roles are considered too permissive for public access.
}

# Helper rule to check if a resource is not being deleted.
# According to "rego.v1" syntax: 'if' keyword before the rule body.
resource_not_deleted(change) if {
    # This rule is true if the 'change.after' field is not null,
    # indicating the resource is being created or updated.
    change.after != null
}

# Deny rule using "rego.v1" 'contains value if condition' syntax.
# This rule checks 'google_storage_bucket_iam_member' resources.
deny contains generated_message if {
    # Iterate through each resource change in the input Terraform plan.
    resource_change := input.resource_changes[_],

    # Condition: The resource type must be 'google_storage_bucket_iam_member'.
    resource_change.type == "google_storage_bucket_iam_member",

    # Condition: The resource must not be undergoing a delete-only action.
    # This calls our helper rule, which itself uses the "rego.v1" 'if' syntax.
    resource_not_deleted(resource_change.change),

    # Assign the planned state of the resource (after apply) to 'config'.
    config := resource_change.change.after,

    # Conditions: Ensure essential attributes exist in the configuration.
    # In Rego, accessing a non-existent field results in 'undefined',
    # which will cause the rule to not be satisfied (acting as a failed condition).
    config.role,
    config.member,
    config.bucket,

    # Condition: The role assigned must be one of the defined public viewer roles.
    public_viewer_roles[config.role],

    # Condition: The member being granted the role must be a public principal.
    public_principals[config.member],

    # If all preceding conditions are true, define the 'generated_message' value.
    # This 'generated_message' is the 'value' part of 'deny contains value'.
    generated_message = sprintf(
        "Public GCS bucket access via iam_member: Bucket '%s' grants role '%s' to '%s'. Resource: '%s'.",
        [config.bucket, config.role, config.member, resource_change.address]
    )
}