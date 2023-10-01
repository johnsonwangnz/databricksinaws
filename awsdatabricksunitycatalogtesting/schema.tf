variable "schema_name" {
  default = "my_schema"
}

resource "databricks_schema" "schema" {

  provider = databricks.ws1
  depends_on   = [ databricks_catalog.catalog,
    databricks_external_location.external_location,
  ]
  catalog_name = databricks_catalog.catalog.name
  name         = var.schema_name
  storage_root = format("s3://%s/%s/%s/managed",
    aws_s3_bucket.external.bucket,
    databricks_catalog.catalog.name,
    var.schema_name)

  force_destroy = true
}