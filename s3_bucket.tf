# Create elasticsearch backup s3 bucket
resource "aws_s3_bucket" "gallerist_es_bucket" {
  bucket = "gallerist-es-backup-main"
  acl    = "private"

  tags = {
    Name        = "Gallerist ElasticSearch Backup Bucket"
    Environment = terraform.workspace
  }
}

# # Create a snapshot repository
# resource "elasticsearch_snapshot_repository" "gallerist_repo" {
#   name = "gallerist-es-backup"
#   type = "s3"
#   settings = {
#     bucket   = aws_s3_bucket.gallerist_es_bucket.bucket
#     region   = "ap-south-1"
#     role_arn = "arn:aws:iam::463432632382:role/elasticsearch_iam_role"
#   }
# }