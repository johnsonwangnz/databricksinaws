
data "aws_caller_identity" "account-a" {
  provider = aws.default
}
# this is instnace role
resource "aws_iam_role" "iam-role-account-a" {
  provider = aws.default
  name        = "${var.prefix}-iam-role-account-a"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}

# this is replaced with resource policy on bucket
resource "aws_iam_policy" "account-a-assume-account-b-policy" {
  provider = aws.default
  name = "${var.prefix}-account-a-assume-account-b-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "${aws_iam_role.iam-role-account-b.arn}"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_policy" "account-a-pass-account-a-policy" {
  provider = aws.default
  name = "${var.prefix}-account-a-pass-account-a-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "${aws_iam_role.iam-role-account-a.arn}"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "account_a_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.iam-role-account-a.name
}
