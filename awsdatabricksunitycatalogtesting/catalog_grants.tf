resource "databricks_grants" "catalog1_grants" {
  depends_on = [databricks_catalog.catalog]
  provider = databricks.ws1
  catalog  = databricks_catalog.catalog.name
  grant {
    principal  = var.unity_admin_group // account users
    privileges = ["ALL_PRIVILEGES"]
  }
}