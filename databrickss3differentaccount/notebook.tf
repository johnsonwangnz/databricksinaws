data "databricks_current_user" me {
  provider = databricks.ws1
}
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

variable "notebook_filename_s3_cross_account" {
  description = "The notebook's filename."
  type = string
  default =  "access_s3_cross_account.sql"
}



variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
  default = "SQL"
}

resource "databricks_notebook" "s3_cross_account" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_s3_cross_account}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_s3_cross_account}"
}



output "notebook_s3_cross_account_url" {
  value = databricks_notebook.s3_cross_account.url
}
