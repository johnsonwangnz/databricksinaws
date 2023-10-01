



resource "databricks_storage_credential" "crossaccount_external" {
  provider = databricks.ws1
  name = aws_iam_role.iam-role-account-b.name
  aws_iam_role {
    role_arn = aws_iam_role.iam-role-account-b.arn
  }
  force_destroy  = true
  comment = "Managed by TF"
}

/**
resource "databricks_grants" "credential_grants" {
  provider = databricks.ws1

  storage_credential = databricks_storage_credential.external.id
  grant {
    principal  =  var.unity_admin_group
    privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
  }
}
**/

resource "databricks_external_location" "crossaccount_external_location" {
  depends_on = []
  provider = databricks.ws1
  name            = "crossaccount_external"
  url             = "s3://${aws_s3_bucket.bucket-account-b.id}/"
  credential_name = databricks_storage_credential.crossaccount_external.id
  # the access is given through assuming role, so validation has to be skipped
  skip_validation = true
  comment         = "Managed by TF"
  force_destroy  = true
}

/**
resource "databricks_grants" "external_location_grant" {
  provider = databricks.ws1
  external_location = databricks_external_location.external_location.id
  grant {
    principal  =  var.unity_admin_group
    privileges = ["CREATE_TABLE", "READ_FILES"]
  }
}
**/
