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
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = var.iam_role_arn == null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.role[0].name
}

resource "aws_iam_role_policy" "ecr" {
  count = var.iam_role_arn == null ? 1 : 0
  role  = aws_iam_role.role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = "arn:aws:ecr:eu-central-1:667740703053:repository/*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
        ]
      },
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
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

  memory_size = local.memory_size
}

resource "aws_lambda_function_url" "container_function_url" {
  count              = local.has_service ? 1 : 0
  function_name      = aws_lambda_function.container_function.function_name
  authorization_type = "AWS_IAM"
}
