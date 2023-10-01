

resource "aws_glue_crawler" "amazon-reviews-crawler" {
  depends_on = [aws_iam_role.GlueServiceRole]
  name = "${var.prefix}-crawler"
  role = aws_iam_role.GlueServiceRole.arn

  database_name = aws_athena_database.my-athena-database.name

  s3_target {
    path = "s3://amazon-reviews-pds/parquet/"
  }

  table_prefix = "amazon_reviews_glue_"

}

################################################################################
# Glue service role
# this is instnace role for ec2 of databricks as well
################################################################################
resource "aws_iam_role" "GlueServiceRole" {
  name               = "${var.prefix}-AWSGlueServiceRole"
  path               = "/"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": ["glue.amazonaws.com", "ec2.amazonaws.com"]},
"Action": "sts:AssumeRole"
}
}
EOF
}

resource "aws_iam_role_policy_attachment" "GlueServiceRole-managed-policy-s3" {
  role       = aws_iam_role.GlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "GlueServiceRole-managed-policy-glue" {
  role       = aws_iam_role.GlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}



resource "aws_iam_instance_profile" "glue_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.GlueServiceRole.name
}
