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
  name        = "s3-upload-api"
  description = "API to generate S3 pre-signed URLs"
}

resource "aws_api_gateway_resource" "resumes" {
  parent_id   = aws_api_gateway_rest_api.app.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.app.id
}

resource "aws_api_gateway_method" "resumes_any_method" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_resource.resumes.id
  rest_api_id   = aws_api_gateway_rest_api.app.id
}

resource "aws_api_gateway_method" "resumes_options_method" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.resumes.id
  rest_api_id   = aws_api_gateway_rest_api.app.id
}


resource "aws_api_gateway_method_response" "options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_resource.resumes.id
  http_method = aws_api_gateway_method.resumes_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_resource.resumes.id
  http_method = aws_api_gateway_method.resumes_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,OPTIONS,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.options_method_response,
    aws_api_gateway_integration.options_integration
  ]
}

# Method response for ANY method
resource "aws_api_gateway_method_response" "any_method_response" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_resource.resumes.id
  http_method = aws_api_gateway_method.resumes_any_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response for ANY method
resource "aws_api_gateway_integration_response" "any_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  resource_id = aws_api_gateway_resource.resumes.id
  http_method = aws_api_gateway_method.resumes_any_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,OPTIONS,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.any_method_response
  ]
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.app.id
  resource_id             = aws_api_gateway_resource.resumes.id
  http_method             = aws_api_gateway_method.resumes_any_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.resumes.invoke_arn
  # credentials             = aws_iam_role.apigw_execution_role.arn //TODO: review cause for 500
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.app.id
  resource_id             = aws_api_gateway_resource.resumes.id
  http_method             = aws_api_gateway_method.resumes_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.integration,
    aws_api_gateway_integration.options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.app.id
}

resource "aws_api_gateway_stage" "app" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.app.id
  stage_name    = "prod"
}

resource "aws_api_gateway_method_settings" "path_specific" {
  rest_api_id = aws_api_gateway_rest_api.app.id
  stage_name  = aws_api_gateway_stage.app.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }

  depends_on = [aws_api_gateway_account.account]
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
