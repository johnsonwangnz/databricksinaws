data "databricks_current_user" me {
  provider = databricks.ws1
}
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

variable "notebook_filename_kinesis" {
  description = "The notebook's filename."
  type = string
  default =  "structured-streaming-kinesis.scala"
}


variable "notebook_filename_kinesis_original" {
  description = "The notebook's filename."
  type = string
  default =  "Integrating_Kinesis.scala"
}


variable "notebook_filename_integrating_external_storage" {
  description = "The notebook's filename."
  type = string
  default =  "Integrating_external_storage.sql"
}

variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
  default = "SCALA"
}

resource "databricks_notebook" "kinesis" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_kinesis}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_kinesis}"
}


resource "databricks_notebook" "integrating_kinesis" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_kinesis_original}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_kinesis_original}"
}


resource "databricks_notebook" "integrating_external_storage" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_integrating_external_storage}"
  language = "SQL"
  source   = "./${var.notebook_filename_integrating_external_storage}"
}


output "notebook_populating_metastore_url" {
  value = databricks_notebook.kinesis.url
}
