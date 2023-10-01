data "aws_iam_role" "cross_account" {
  name = "${var.prefix}-crossaccount"
}


resource "aws_iam_policy" "assume-role-policy" {
  name = "${var.prefix}-assume-role-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Sid": "AssumeRole",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "${aws_iam_role.autoloader-role.arn}"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "add-passrole-policies" {
  for_each =  {
    policy1 = aws_iam_policy.assume-role-policy.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = data.aws_iam_role.cross_account.name
  policy_arn = each.value
}