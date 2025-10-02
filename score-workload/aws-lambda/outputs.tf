locals {
  endpoint = local.has_service ? aws_lambda_function_url.container_function_url[0].function_url : ""
}

output "endpoint" {
  value = local.endpoint
}

output "function_arn" {
  value = aws_lambda_function.container_function.arn
}

output "humanitec_metadata" {
  value = {
    Region      = aws_lambda_function.container_function.region
    Console-Url = "https://${aws_lambda_function.container_function.region}.console.aws.amazon.com/lambda/home?region=${aws_lambda_function.container_function.region}#/functions/${aws_lambda_function.container_function.function_name}"
    Web-Url     = local.endpoint
  }
}
