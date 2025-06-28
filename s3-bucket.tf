resource "aws_s3_bucket" "rs_bucket" {
  bucket = "rs-terraform-c"
}

resource "aws_s3_bucket_versioning" "rs_bucket_versioning" {
  bucket = aws_s3_bucket.rs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rs_bucket_encryption" {
  bucket = aws_s3_bucket.rs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
