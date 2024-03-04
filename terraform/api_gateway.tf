resource "aws_api_gateway_rest_api" "image_api" {
  name        = "ImageUploadAPI"
}

resource "aws_api_gateway_resource" "image_resource" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  parent_id   = aws_api_gateway_rest_api.image_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_api_key" "image_api_key" {
  name = "ImageUploadAPIKey"
  description = "API key for image upload service"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "image_api_usage_plan" {
  name        = "ImageUploadAPIUsagePlan"
  description = "Usage plan for image upload API"
  api_stages {
    api_id = aws_api_gateway_rest_api.image_api.id
    stage  = aws_api_gateway_deployment.image_api_deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "image_api_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.image_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.image_api_usage_plan.id
}

resource "aws_api_gateway_method" "image_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.image_api.id
  resource_id   = aws_api_gateway_resource.image_resource.id
  http_method   = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "image_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  resource_id = aws_api_gateway_resource.image_resource.id
  http_method = aws_api_gateway_method.image_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image_uploader.invoke_arn
}

resource "aws_api_gateway_deployment" "image_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.image_lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.image_api.id
  stage_name  = "v1"
}

resource "aws_lambda_permission" "allow_api_gateway_call" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_uploader.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_api.execution_arn}/*/*/*"
}

output "api_key_value" {
  value     = aws_api_gateway_api_key.image_api_key.value
  sensitive = true
}

output "api_gateway_api_endpoint" {
  value = aws_api_gateway_deployment.image_api_deployment.invoke_url
}

