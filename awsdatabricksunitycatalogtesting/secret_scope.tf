resource "databricks_secret_scope" "this" {
  provider = databricks.ws1
  name = "${data.databricks_current_user.me.alphanumeric}-scope"
}

resource "databricks_token" "pat" {
  provider = databricks.ws1
  comment          = "Created from ${abspath(path.module)}"
  lifetime_seconds = 3600
}

resource "databricks_secret" "token" {
  provider = databricks.ws1
  string_value = databricks_token.pat.token_value
  scope        = databricks_secret_scope.this.name
  key          = "token"
}

resource "databricks_notebook" "this" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/Testing"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
    token = dbutils.secrets.get('${databricks_secret_scope.this.name}', '${databricks_secret.token.key}')
    print(f'This should be redacted: {token}')
    EOT
  )
}

resource "databricks_permissions" "notebook" {
  provider = databricks.ws1
  notebook_path = databricks_notebook.this.id
  access_control {

    group_name        = databricks_group.dbacademy_analysts.display_name
    permission_level = "CAN_RUN"
  }
  /**
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_READ"
  }**/
}