
data "aws_caller_identity" "account-b" {
  provider = aws.jwawsadmin
}
# this is instnace role
resource "aws_iam_role" "iam-role-account-b" {
  provider = aws.jwawsadmin
  name        = "${var.prefix}-iam-role-account-b"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"AWS": "${aws_iam_role.iam-role-account-a.arn}"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}

