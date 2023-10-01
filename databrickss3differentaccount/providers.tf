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
  alias = "default"
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

