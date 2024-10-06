# S3 Bucket for uploads
resource "aws_s3_bucket" "resumes_bucket" {
  bucket = "aurora-resumes-s456"
}

resource "aws_s3_bucket_policy" "resumes_bucket" {
  bucket = aws_s3_bucket.resumes_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_role.apigw_execution_role.arn}"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.resumes_bucket.arn}/*",
          "${aws_s3_bucket.resumes_bucket.arn}"
        ]
      }
    ]
  })
}
