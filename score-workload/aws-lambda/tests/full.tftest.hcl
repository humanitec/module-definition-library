mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/lambda-role"
    }
  }
}

mock_provider "random" {
  mock_resource "random_id" {
    defaults = {
      hex = "abcdef"
    }
  }
}

run "plan" {
  variables {
    metadata = {
      name = "deployment-sparse"
    }

    containers = {
      "main" = {
        image   = "nginx:latest"
        command = ["/bin/sh"]
        args    = ["-c", "echo"]
        variables = {
          A = "B"
        }
        resources = {
          limits = {
            memory = "128M"
          }
        }
      }
    }

    service = {
      ports = {
        invoke = {
          port = 80
        }
      }
    }

    aws_region            = "us-east-1"
    iam_role_arn          = "arn:aws:iam::123456789012:role/custom-role"
    architectures         = ["arm64"]
    timeout_in_seconds    = 10
    is_ecr_policy_enabled = false
    additional_labels = {
      "A" : "B",
    }
  }

  command = plan

  assert {
    condition     = length(tolist(aws_iam_role.role)) == 0
    error_message = "expected no iam role to be generated"
  }

  assert {
    condition     = can(aws_iam_role_policy_attachment.lambda_basic.role)
    error_message = "expected an lambda_basic policy to be generated"
  }

  assert {
    condition     = can(aws_lambda_function_url.container_function_url[0])
    error_message = "expected a function url"
  }
}
