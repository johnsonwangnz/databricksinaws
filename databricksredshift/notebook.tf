
data "databricks_current_user" me {
  provider = databricks.ws1
}
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

variable "notebook_filename_redshift" {
  description = "The notebook's filename."
  type = string
  default =  "integrating_redshift.sql"
}


variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
  default = "SQL"
}

resource "databricks_notebook" "notebook-1" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_redshift}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_redshift}"
}


output "notebook_1_url" {
  value = databricks_notebook.notebook-1.url
}
