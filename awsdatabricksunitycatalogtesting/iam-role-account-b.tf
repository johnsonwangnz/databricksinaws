
data "aws_caller_identity" "account-b" {
  provider = aws.jwawsadmin
}



# this is instnace role
# self assuming not working? add this manually
#    "arn:aws:iam::${data.aws_caller_identity.account-b.account_id}:role/${var.prefix}-iam-role-account-b"

resource "aws_iam_role" "iam-role-account-b" {
  provider = aws.jwawsadmin
  name        = "${var.prefix}-iam-role-account-b"
  description = "The role for the developer resources EC2"
  # cannot use data.aws_iam_policy_document for self referencing
  # add the self assuming after the creation of role
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {"AWS": [
                "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"

              ]},
            "Action": "sts:AssumeRole",
            "Condition" : {
                "StringEquals" : {
                    "sts:ExternalId" : "${var.databricks_account_id}"
                }
            }
        }
    }
EOF
  tags = {
    stack = "test"
  }
}



resource "aws_iam_policy" "account-b-s3-access" {
  provider = aws.jwawsadmin
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
           "${aws_s3_bucket.bucket-account-b.arn}",
          "${aws_s3_bucket.bucket-account-b.arn}/*"
        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.prefix}-unity-catalog external access to log IAM policy"
  })
}




resource "aws_iam_role_policy_attachment" "iam-role-account-b-policies" {
  provider = aws.jwawsadmin
  for_each =  {
    policy1 = aws_iam_policy.account-b-s3-access.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.iam-role-account-b.name
  policy_arn = each.value
}
