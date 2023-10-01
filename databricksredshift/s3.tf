resource "aws_s3_bucket" "redshift-temp-bucket" {
  bucket        = "${var.prefix}-redshifttempbucket"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-redshifttempbucket"
  })
}


resource "aws_s3_bucket_lifecycle_configuration" "redshift-temp-bucket-config" {
  bucket = aws_s3_bucket.redshift-temp-bucket.id

  rule {
    id = "allfiles"

    expiration {
      days = 1
    }

    status = "Enabled"
  }

}


resource "aws_s3_object" "users_file" {

  bucket       = aws_s3_bucket.redshift-temp-bucket.id
  key    = "data/allusers_pipe.txt"
  source = "data/allusers_pipe.txt"

}


output "s3_bucket" {
  value = aws_s3_bucket.redshift-temp-bucket.bucket
}

