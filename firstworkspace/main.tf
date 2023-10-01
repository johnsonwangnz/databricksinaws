resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "jw${random_string.naming.result}"
}

output "local_prefx" {
  value = local.prefix
}