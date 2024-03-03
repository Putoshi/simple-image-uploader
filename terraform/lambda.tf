resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
    }],
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:PutObject",
        "s3:GetObject"  # ここに追加
      ],
      Effect   = "Allow",
      Resource = "${aws_s3_bucket.image_bucket.arn}/*",
    }],
  })
}

resource "aws_lambda_function" "image_uploader" {
  function_name = "imageUploader"

  s3_bucket = aws_s3_bucket.image_bucket.bucket
  s3_key    = "image-uploader.zip"

  handler = "index.handler"
  runtime = "nodejs20.x"
  role    = aws_iam_role.lambda_execution_role.arn
  
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.image_bucket.bucket
    }
  }
}
