

resource "aws_iam_instance_profile" "autoloader_instance_profile" {
  depends_on = [aws_iam_role.autoloader-role]
  name = "${var.prefix}autoloaderprofile"
  role = aws_iam_role.autoloader-role.name
}

resource "databricks_instance_profile" "autoloader_instance_profile" {
  provider   = databricks.ws1
  instance_profile_arn = aws_iam_instance_profile.autoloader_instance_profile.arn
}
