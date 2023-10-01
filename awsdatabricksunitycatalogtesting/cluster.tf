variable "cluster_name" {
  default = "My Cluster"
}
variable "cluster_autotermination_minutes" {
  default = 60
}

variable "cluster_num_workers" {
  default = 2
}

# USER_ISOLATION shared,SINGLE_USER
variable "cluster_data_security_mode" {
  default = "USER_ISOLATION"
}

# Create the cluster with the "smallest" amount
# of resources allowed.
data "databricks_node_type" "smallest" {
  provider             = databricks.ws1
  local_disk = true
}

# Use the latest Databricks Runtime
# Long Term Support (LTS) version.
data "databricks_spark_version" "latest_lts" {
  provider             = databricks.ws1
  long_term_support = true
}

resource "databricks_cluster" "this" {
  provider             = databricks.ws1
  cluster_name            = var.cluster_name
  node_type_id            = data.databricks_node_type.smallest.id
  spark_version           = data.databricks_spark_version.latest_lts.id
  autotermination_minutes = var.cluster_autotermination_minutes
  num_workers             = var.cluster_num_workers
  data_security_mode      = var.cluster_data_security_mode
  lifecycle {
    ignore_changes = [ single_user_name ]
  }
}

resource "databricks_permissions" "cluster_usage" {
  provider             = databricks.ws1
  cluster_id = databricks_cluster.this.id

  access_control {
    group_name       = databricks_group.dbacademy_analysts.display_name
    permission_level = "CAN_ATTACH_TO"
  }

}


output "cluster_url" {
  value = databricks_cluster.this.url
}

