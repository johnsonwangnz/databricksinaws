
resource "aws_kinesis_stream" "input-stream" {
  name             = "${var.prefix}-input-stream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  enforce_consumer_deletion = true
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "test"
  }
}
