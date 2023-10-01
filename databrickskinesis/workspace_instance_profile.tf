resource "databricks_instance_profile" "kinesis_instance_profile" {
  provider   = databricks.ws1
  instance_profile_arn = aws_iam_instance_profile.kinesis_instance_profile.arn
}
