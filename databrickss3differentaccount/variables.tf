
variable "databricks_account_id" {
  type = string

}

variable "databricks_workspace_id" {
  description = <<EOT
  List of Databricks workspace IDs to be enabled with Unity Catalog.
  Enter with square brackets and double quotes
  e.g. ["111111111", "222222222"]
  EOT
  type        = string

}


variable "tags" {
  default = {}
}


variable "region" {
  type    = string
  default = "ap-southeast-1"
}


variable "databricks_metastore_id" {
  type    = string

}


# this is the output from previous project
variable "prefix" {
  type        = string

}


variable "unity_admin_group" {
  description = "Name of the admin group. This group will be set as the owner of the Unity Catalog metastore"
  type        = string
  default = "Bootstrap admin group"
}

