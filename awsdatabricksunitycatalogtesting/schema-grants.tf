
variable "schema_privileges" {
  default = [ "ALL_PRIVILEGES" ]
}


resource "databricks_grants" "schema" {
  provider = databricks.ws1
  depends_on = [ databricks_schema.schema ]
  schema = databricks_schema.schema.id

  grant {
    principal  =  var.unity_admin_group
    privileges = var.schema_privileges
  }
}