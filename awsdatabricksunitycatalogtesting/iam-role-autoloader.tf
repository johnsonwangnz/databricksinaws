

# this is instnace role
# self assuming not working? add this manually
#    "arn:aws:iam::${data.aws_caller_identity.account-b.account_id}:role/${var.prefix}-iam-role-account-b"

resource "aws_iam_role" "autoloader-role" {
  name        = "${var.prefix}-autoloader-role"
  description = "The role for the developer resources EC2"

  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
           {
                "Effect": "Allow",
                "Principal": {"Service": "ec2.amazonaws.com"},
                "Action": "sts:AssumeRole"
            },
          {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}-autoloader-role"
            },
            "Action": "sts:AssumeRole"
          }

        ]
    }
EOF
  tags = {
    stack = "test"
  }
}



resource "aws_iam_policy" "autoloader-s3-access" {

  // Terraform's "jsonencode" function converts a
  // Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${aws_s3_bucket.autoloader-bucket.id}-access"
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
           "${aws_s3_bucket.autoloader-bucket.arn}",
          "${aws_s3_bucket.autoloader-bucket.arn}/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Sid": "DatabricksAutoLoaderSetup",
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:CreateTopic",
          "sns:TagResource",
          "sns:Publish",
          "sns:Subscribe",
          "sqs:CreateQueue",
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:SetQueueAttributes",
          "sqs:TagQueue",
          "sqs:ChangeMessageVisibility"
        ],
        "Resource": [
          "${aws_s3_bucket.autoloader-bucket.arn}",
          "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:databricks-auto-ingest-*",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:databricks-auto-ingest-*"
        ]
      },
      {
        "Sid": "DatabricksAutoLoaderList",
        "Effect": "Allow",
        "Action": [
          "sqs:ListQueues",
          "sqs:ListQueueTags",
          "sns:ListTopics"
        ],
        "Resource": "*"
      },
      {
        "Sid": "DatabricksAutoLoaderTeardown",
        "Effect": "Allow",
        "Action": [
          "sns:Unsubscribe",
          "sns:DeleteTopic",
          "sqs:DeleteQueue"
        ],
        "Resource": [
          "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:databricks-auto-ingest-*",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:databricks-auto-ingest-*"
        ]
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.prefix}-unity-catalog external access to log IAM policy"
  })
}




resource "aws_iam_role_policy_attachment" "autoloader-role-attached-policies" {

  for_each =  {
    policy1 = aws_iam_policy.autoloader-s3-access.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.autoloader-role.name
  policy_arn = each.value
}

