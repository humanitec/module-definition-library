terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "aws_iam_role" "role" {
  count       = var.iam_role_arn == null ? 1 : 0
  name_prefix = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = var.additional_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = var.iam_role_arn == null ? aws_iam_role.role[0].name : var.iam_role_arn
}

resource "aws_iam_role_policy" "ecr" {
  count = var.iam_role_arn == null && var.is_ecr_policy_enabled ? 1 : 0
  role  = aws_iam_role.role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "random_id" "entropy" {
  byte_length = 4
}

locals {
  has_service = try(length(var.service.ports), 0) > 0

  parts = regex("(\\d+)([MG])$", var.containers.main.resources.limits.memory)

  memory_size = local.parts[1] == "G" ? tonumber(local.parts[0]) * 1000 : tonumber((local.parts[0]))
}

resource "aws_lambda_function" "container_function" {
  function_name = "score-workload-${random_id.entropy.hex}"
  role          = var.iam_role_arn != null ? var.iam_role_arn : aws_iam_role.role[0].arn
  region        = var.aws_region

  package_type = "Image"
  image_uri    = var.containers.main.image
  image_config {
    entry_point = var.containers.main.command
    command     = var.containers.main.args
  }

  environment {
    variables = var.containers.main.variables
  }

  architectures = var.architectures

  timeout     = var.timeout_in_seconds
  memory_size = local.memory_size

  tags = var.additional_tags
}

resource "aws_lambda_function_url" "container_function_url" {
  count              = local.has_service ? 1 : 0
  function_name      = aws_lambda_function.container_function.function_name
  authorization_type = lookup(coalesce(try(var.metadata.annotations, null), {}), "score.humanitec.dev/function-invoke-authorization", "AWS_IAM")
}
