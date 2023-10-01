data "databricks_current_user" me {
  provider = databricks.ws1
}
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

variable "notebook_filename_populating_metastore" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "Creating_and_governing_data_objects.sql"
}
variable "notebook_filename_managing_external_storage" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "Managing_external_storage.sql"
}


variable "notebook_filename_log_analysis" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "log_analysis.sql"
}


variable "notebook_filename_crossaccount" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "access_s3_cross_account.sql"
}

variable "notebook_filename_unity_volumes" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "unity-catalog-volumes.sql"
}


variable "notebook_filename_autoloader" {
  description = "The notebook's filename."

  type = string
  #default = "notebook-getting-started-lakehouse-e2e.py"
  default =  "autoloader.sql"
}

variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
  default = "SQL"
}

resource "databricks_notebook" "populating_metastore" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_populating_metastore}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_populating_metastore}"
}


resource "databricks_notebook" "managing_external_storage" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_managing_external_storage}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_managing_external_storage}"
}


resource "databricks_notebook" "log_analysis" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_log_analysis}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_log_analysis}"
}


resource "databricks_notebook" "crossaccount" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_crossaccount}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_crossaccount}"
}


resource "databricks_notebook" "unity_volumes" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_unity_volumes}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_unity_volumes}"
}


resource "databricks_notebook" "autoloader" {
  provider = databricks.ws1
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename_autoloader}"
  language = var.notebook_language
  source   = "./${var.notebook_filename_autoloader}"
}


output "notebook_populating_metastore_url" {
  value = databricks_notebook.populating_metastore.url
}
