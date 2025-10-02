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
        image = "nginx:latest"
        command = ["/bin/sh"]
        args = ["-c", "echo"]
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

    region = "us-east-1"
    iam_role_arn = "arn:aws:iam::123456789012:role/custom-role"
    architectures = ["arm64"]
  }

  command = plan

  assert {
    condition = length(tolist(aws_iam_role.role)) == 0
    error_message = "expected no iam role to be generated"
  }

  assert {
    condition = length(tolist(aws_lambda_function_url.container_function_url)) > 0
    error_message = "expected a function url"
  }
}
