# account group
resource "databricks_group" "dbacademy_analysts" {
  provider     = databricks.mws
  display_name = "dbacademy_analysts"
}

# to assign account group to workspace group
resource "databricks_mws_permission_assignment" "add_dbacademy_analysts_group" {
  provider     = databricks.mws
  workspace_id = var.databricks_workspace_id
  principal_id = databricks_group.dbacademy_analysts.id

  # USER for basic, ADMIN for admin group
  permissions  = ["USER"]
}

