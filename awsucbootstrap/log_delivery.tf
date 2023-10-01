resource "aws_s3_bucket" "logdelivery" {
  bucket        = "${var.prefix}-logdelivery-databricks"

  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-logdelivery"
  })
}


data "databricks_aws_assume_role_policy" "logdelivery" {
  provider     = databricks.mws
  external_id      = var.databricks_account_id
  for_log_delivery = true
}

resource "aws_s3_bucket_versioning" "logdelivery_versioning" {
  bucket = aws_s3_bucket.logdelivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_iam_role" "logdelivery" {
  name               = "${var.prefix}-logdelivery"
  description        = "(${var.prefix}) UsageDelivery role"
  assume_role_policy = data.databricks_aws_assume_role_policy.logdelivery.json
  tags               = var.tags
}

data "databricks_aws_bucket_policy" "logdelivery" {
  provider     = databricks.mws
  full_access_role = aws_iam_role.logdelivery.arn
  bucket           = aws_s3_bucket.logdelivery.bucket
}

resource "aws_s3_bucket_policy" "logdelivery" {
  bucket = aws_s3_bucket.logdelivery.id
  policy = data.databricks_aws_bucket_policy.logdelivery.json
}

# this is for control plan to write logs to a location
# it is different from notebook/uc accesses to data
resource "databricks_mws_credentials" "log_writer" {
  provider     = databricks.mws
  account_id       = var.databricks_account_id
  credentials_name = "Usage Delivery"
  role_arn         = aws_iam_role.logdelivery.arn
}

resource "databricks_mws_storage_configurations" "log_bucket" {
  provider     = databricks.mws
  account_id                 = var.databricks_account_id
  storage_configuration_name = "Usage Logs"
  bucket_name                = aws_s3_bucket.logdelivery.bucket
}

resource "databricks_mws_log_delivery" "usage_logs" {
  provider     = databricks.mws
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "billable-usage"
  config_name              = "Usage Logs"
  log_type                 = "BILLABLE_USAGE"
  output_format            = "CSV"
}

resource "databricks_mws_log_delivery" "audit_logs" {
  provider     = databricks.mws
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
}