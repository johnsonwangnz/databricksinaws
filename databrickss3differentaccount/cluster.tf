variable "cluster_name" {
  default = "Job Cluster"
}
variable "cluster_autotermination_minutes" {
  default = 20
}

variable "cluster_num_workers" {
  default = 2
}

# USER_ISOLATION shared,SINGLE_USER
variable "cluster_data_security_mode" {
  default = "SINGLE_USER"
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

  aws_attributes {
    instance_profile_arn   = databricks_instance_profile.databricks_instance_profile.id

  }

  spark_conf = {
    "fs.s3a.bucket.${aws_s3_bucket.bucket-account-b.bucket}.aws.credentials.provider": "org.apache.hadoop.fs.s3a.auth.AssumedRoleCredentialProvider",
    "fs.s3a.bucket.${aws_s3_bucket.bucket-account-b.bucket}.assumed.role.arn": "${aws_iam_role.iam-role-account-b.arn}"
   }


  lifecycle {
    ignore_changes = [ single_user_name ]
  }
}



output "cluster_url" {
  value = databricks_cluster.this.url
}

