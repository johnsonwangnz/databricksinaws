# this is instnace role
resource "aws_iam_role" "redshift-instance-role" {
  name        = "${var.prefix}-redshift-instance-role"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service":
    ["ec2.amazonaws.com","redshift.amazonaws.com" ]},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}

resource "aws_iam_policy" "s3-policy" {
  name = "${var.prefix}-s3-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Sid": "AllowS3Bucket",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.redshift-temp-bucket.arn}/*"
            ]
    },
    {
            "Sid": "AllowListS3Bucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.redshift-temp-bucket.arn}"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "develop-role-policies" {
  for_each =  {
    policy1 = aws_iam_policy.s3-policy.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.redshift-instance-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "redshift_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.redshift-instance-role.name
}