
# this is the s3 that will be used as autoloader source, and readonly

resource "aws_s3_bucket" "autoloader-bucket" {
  bucket        = "${var.prefix}-autoloader-bucket"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-autoloader-bucket"
  })
}
