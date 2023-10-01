

# attach log access to external access role
resource "aws_iam_role_policy_attachment" "log-access-policies" {
  for_each =  {
    policy1 = aws_iam_policy.log_data_access.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.external_data_access.name
  policy_arn = each.value
}


resource "databricks_external_location" "external_log_location" {
  depends_on = [aws_iam_role_policy_attachment.log-access-policies]
  provider = databricks.ws1
  name            = "external_log"
  url             = "s3://${data.aws_s3_bucket.log_bucket.id}/"
  # using the same external storage credential
  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
  force_destroy  = true
}


