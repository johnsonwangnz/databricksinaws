resource "databricks_instance_profile" "glue_instance_profile" {
  depends_on = [aws_iam_role.GlueServiceRole]
  provider   = databricks.ws1
  instance_profile_arn = aws_iam_instance_profile.glue_instance_profile.arn
}
