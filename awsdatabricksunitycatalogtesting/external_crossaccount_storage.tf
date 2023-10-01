
# this is the s3 in a different account
resource "aws_s3_bucket" "bucket-account-b" {
  provider = aws.jwawsadmin
  bucket        = "${var.prefix}-account-b"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-account-b"
  })
}

/**
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  provider = aws.jwawsadmin
  bucket = aws_s3_bucket.bucket-account-b.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${aws_iam_role.iam-role-account-b.arn}"
                      ]
            },
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.bucket-account-b.arn}"
            ]
    },
    {

            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${aws_iam_role.iam-role-account-b.arn}"
                      ]
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.bucket-account-b.arn}/*"
            ]
    }
  ]
}
EOF
}

**/