

variable "databricks_account_id" {
  type = string

}

variable "databricks_users" {
  description = <<EOT
  List of Databricks users to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.last@domain.com", "second.last@domain.com"]
  EOT
  type        = list(string)
  default = []
}

#do not put account owner in this list, add emails of the account admins

variable "databricks_account_admins" {
  description = <<EOT
  List of Admins to be added at account-level for Unity Catalog.
  Enter with square brackets and double quotes
  e.g ["first.admin@domain.com", "second.admin@domain.com"]
  EOT
  type        = list(string)
  default = []
}


variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "unity_admin_group" {
  description = "Name of the admin group. This group will be set as the owner of the Unity Catalog metastore"
  type        = string
  default = " Bootstrap admin group"
}

# this is the output from previous project,also the workspace name
variable "prefix" {
  type        = string

}


variable "tags" {
  default = {}
}


variable "databricks_account_username" {
  type = string
}

variable "databricks_account_password" {
  type = string
}

