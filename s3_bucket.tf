# Create elasticsearch backup s3 bucket
resource "aws_s3_bucket" "example_es_bucket" {
  bucket = "example-es-backup"
  acl    = "private"

  tags = {
    Name        = "Example ElasticSearch Backup Bucket"
    Environment = terraform.workspace
  }
}
