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
  region = var.region
}

provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id // like a shared account? HA from multiple email accounts
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  = "basic"
}

// create users and groups at account level (not workspace user/group)
resource "databricks_user" "unity_users" {
  provider  = databricks.mws
  for_each  = toset(concat(var.databricks_users, var.databricks_account_admins))
  user_name = each.key
  force     = true
}

resource "databricks_group" "admin_group" {
  provider     = databricks.mws
  display_name = var.unity_admin_group
}

resource "databricks_group_member" "admin_group_member" {
  provider  = databricks.mws
  for_each  = toset(var.databricks_account_admins)
  group_id  = databricks_group.admin_group.id
  member_id = databricks_user.unity_users[each.value].id
}


resource "databricks_user_role" "account_admin_role" { // this group is admin for metastore, also pre-requisite for creating metastore
  provider = databricks.mws
  for_each = toset(var.databricks_account_admins)
  user_id  = databricks_user.unity_users[each.value].id
  role     = "account_admin"
}

data "databricks_mws_workspaces" "all" {
  provider     = databricks.mws
}

# to assign account group to workspace group
resource "databricks_mws_permission_assignment" "add_admin_group" {
  provider     = databricks.mws
  workspace_id = data.databricks_mws_workspaces.all.ids[var.prefix]
  principal_id = databricks_group.admin_group.id

  # USER for basic, ADMIN for admin group
  permissions  = ["ADMIN"]
}

output "all_mws_workspaces" {
  value = data.databricks_mws_workspaces.all.ids
}

