resource "databricks_sql_endpoint" "this" {
  provider = databricks.ws1
  name             = "Endpoint of ${data.databricks_current_user.me.alphanumeric}"
  cluster_size     = "Small"
  max_num_clusters = 1

  tags {
    custom_tags {
      key   = "City"
      value = "Amsterdam"
    }
  }
}