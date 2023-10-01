
# this is the s3 log folder
data "aws_s3_bucket" "log_bucket" {
  bucket = "${var.prefix}-logdelivery-databricks"
}


resource "aws_iam_policy" "log_data_access" {
  // Terraform's "jsonencode" function converts a
  // Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${data.aws_s3_bucket.log_bucket.id}-access"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          data.aws_s3_bucket.log_bucket.arn,
          "${data.aws_s3_bucket.log_bucket.arn}/*"
        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.prefix}-unity-catalog external access to log IAM policy"
  })
}