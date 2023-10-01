terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  #alias = "default"
  profile = "default"
  region = var.region
}


provider "aws" {
  alias = "jwawsadmin"
  profile = "jwawsadmin"
  region = var.region
}


provider "databricks" {
  alias = "ws1"
  profile = "awsucdev"
}


# used to provision test users
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id // like a shared account? HA from multiple email accounts
  # not to user environment variables, it messes up the workspace providers
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  = "basic"
}
