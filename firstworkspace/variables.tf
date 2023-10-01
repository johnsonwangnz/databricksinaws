#variable "databricks_account_username" {}
#variable "databricks_account_password" {}
variable "databricks_account_id" {
  type = string

}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "ap-southeast-1"
}


variable "databricks_account_username" {
  type = string
}

variable "databricks_account_password" {
  type = string
}
