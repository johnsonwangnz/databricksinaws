# this is instnace role
resource "aws_iam_role" "kinesis-instance-role" {
  name        = "${var.prefix}-kinesis-instance-role"
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

resource "aws_iam_policy" "kinesis-analytics-service-policy" {
  name = "${var.prefix}-kinesis-analytics-service-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Sid": "KinesisTopic",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary",
                "kinesis:RegisterStreamConsumer",
                "kinesis:GetShardIterator",
                "kinesis:PutRecord",
                "kinesis:PutRecords",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": [
                "${aws_kinesis_stream.input-stream.arn}"
            ]
    },
    {
            "Sid": "WriteOutputKinesis",
            "Effect": "Allow",
            "Action": [
                "kinesis:SubscribeToShard",
                "kinesis:DescribeStreamConsumer"
            ],
            "Resource": [
                "${aws_kinesis_stream.input-stream.arn}/*"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "develop-role-policies" {
  for_each =  {
    policy1 = aws_iam_policy.kinesis-analytics-service-policy.arn


    # Works with AWS Provided policies too!
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  role       = aws_iam_role.kinesis-instance-role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "kinesis_instance_profile" {
  name = "${var.prefix}_instance_profile"
  role = aws_iam_role.kinesis-instance-role.name
}