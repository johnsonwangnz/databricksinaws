
resource "databricks_user" "test_user" {
  provider     = databricks.mws
  user_name = "johnsonwangnz@gmail.com"
  databricks_sql_access = true
  force_delete_home_dir = true
  force = true
  # remove the user after deletion, default is disable
  disable_as_user_deletion = false
}

resource "databricks_group_member" "test_user_member" {
  provider     = databricks.mws
  group_id  = databricks_group.dbacademy_analysts.id
  member_id = databricks_user.test_user.id
}


# add account user to workspace
# as we did in group, so we do not need this one
#resource "databricks_mws_permission_assignment" "add_admin_group" {
#  workspace_id = databricks_mws_workspaces.this.workspace_id
#  principal_id = databricks_group.data_eng.id
#  permissions  = ["ADMIN"]
#}
