resource "random_id" "entropy" {
    byte_length = 4
}

resource "aws_iam_role" "role" {
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "ecr" {
  role = aws_iam_role.role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = "arn:aws:ecr:eu-central-1:667740703053:repository/*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
      },
      {
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "container_function" {
  function_name = "platform-demo-container-${random_id.entropy.hex}"
  role         = aws_iam_role.role.arn
  
  package_type = "Image"
  image_uri    = "667740703053.dkr.ecr.eu-central-1.amazonaws.com/bentesting/demo-lambda:latest"
  
  timeout     = 30
  memory_size = 512
}

resource "aws_lambda_function_url" "container_function_url" {
  function_name      = aws_lambda_function.container_function.function_name
  authorization_type = "NONE"
}

output "endpoint" {
  value       = aws_lambda_function_url.container_function_url.function_url
}
