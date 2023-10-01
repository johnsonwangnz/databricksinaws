variable "catalog_name" {
  default = "catalog1"
}

resource "databricks_catalog" "catalog" {
  provider = databricks.ws1
  metastore_id = var.databricks_metastore_id
  name         = var.catalog_name
  comment      = "this catalog is managed by terraform"
}