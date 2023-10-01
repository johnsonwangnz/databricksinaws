resource "databricks_instance_profile" "redshift_instance_profile" {
  depends_on = [aws_iam_role.redshift-instance-role]
  provider   = databricks.ws1
  instance_profile_arn = aws_iam_instance_profile.redshift_instance_profile.arn
}
