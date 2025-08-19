resource "aws_s3_bucket" "my_bucket" {
  bucket = "filbert-tf-state-bucket"

  tags = {
    Name        = "filbert-tf-state-bucket"
    Project = "DevOps"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}