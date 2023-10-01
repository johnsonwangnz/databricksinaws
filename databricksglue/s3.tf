
resource "aws_s3_bucket" "athena-workshop-bucket" {
  bucket = "${var.prefix}-athena-workshop"
  # when delete bucket, delete content
  force_destroy = true
}

