resource "databricks_instance_profile" "databricks_instance_profile" {
  provider   = databricks.ws1
  instance_profile_arn = aws_iam_instance_profile.account_a_instance_profile.arn
}
