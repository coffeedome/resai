/*
API Gateway Execution Role and policies
*/
resource "aws_iam_role" "apigw_execution_role" {
  name = "aurora_api_gw_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gw_s3_policy" {
  name = "APIGatewayDirectS3AccessPolicy"
  role = aws_iam_role.apigw_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      Resource = "${aws_s3_bucket.resumes_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy" "api_gw_lambda_policy" {
  name = "APIGatewayLambdaAccess"
  role = aws_iam_role.apigw_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "lambda:InvokeFunction"
      ],
      Resource = "${aws_lambda_function.resumes.arn}"
    }]
  })
}


resource "aws_iam_role_policy" "api_gateway_logs_policy" {
  name = "APIGatewayLogsPolicy"
  role = aws_iam_role.apigw_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.api_gateway_logs.arn}:*"
      },
    ]
  })
}

resource "aws_api_gateway_rest_api" "app" {
  name        = "ResponsibleAI"
  description = "Responsible AI APIs"
  body        = templatefile("${path.module}/api-gateway-spec.yaml")
}



resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_policy" {
  role       = aws_iam_role.apigw_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigw_execution_role.arn
}

output "api_endpoint" {
  value = "${aws_api_gateway_rest_api.app.execution_arn}/resumes"
}

output "invoke_arn_lambda" {
  value = aws_lambda_function.resumes.invoke_arn
}

output "api_url" {
  value       = "https://${aws_api_gateway_rest_api.app.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.app.stage_name}"
  description = "The API Gateway URL"
}
