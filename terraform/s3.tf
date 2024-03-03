resource "aws_s3_bucket" "image_bucket" {
  bucket = "image-upload-bucket-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "image_bucket" {
  bucket = aws_s3_bucket.image_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "image_bucket" {
  bucket = aws_s3_bucket.image_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "s3:GetObject",
        Effect    = "Allow",
        Resource  = "${aws_s3_bucket.image_bucket.arn}/uploads/*",
        Principal = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "image_bucket_cors" {
  bucket = aws_s3_bucket.image_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }
}

resource "aws_s3_bucket_acl" "image_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.image_bucket,
    aws_s3_bucket_public_access_block.image_bucket,
  ]

  bucket = aws_s3_bucket.image_bucket.id
  acl    = "public-read"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}
