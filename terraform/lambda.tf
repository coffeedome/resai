/*
AWS Lambda
*/
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_lambda_execution_role" {
  name               = "aurora_lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.aws_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "resumes" {
  filename      = "resumes_api.zip"
  function_name = "resumes-api"
  role          = aws_iam_role.aws_lambda_execution_role.arn
  handler       = "resumes_api.app.lambda_handler"
  runtime       = "python3.11"

  memory_size = 128
  timeout     = 30

  source_code_hash = filebase64sha256("resumes_api.zip")

  environment {
    variables = {
      RESUMES_S3_BUCKET_NAME = "${aws_s3_bucket.resumes_bucket.id}"
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resumes.function_name
  principal     = "apigateway.amazonaws.com"

  #source_arn = "${aws_api_gateway_rest_api.app.execution_arn}/*/*/resumes"
  source_arn = "${aws_api_gateway_rest_api.app.execution_arn}/*/*"
}


