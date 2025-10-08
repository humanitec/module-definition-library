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
        resources = {
          limits = {
            memory = "128M"
          }
        }
      }
    }
  }

  command = plan

  assert {
    condition     = can(aws_iam_role.role[0])
    error_message = "expected an iam role to be generated"
  }

  assert {
    condition     = can(aws_iam_role_policy_attachment.lambda_basic.role)
    error_message = "expected an lambda_basic policy to be generated"
  }

  assert {
    condition     = can(aws_iam_role_policy.ecr[0])
    error_message = "expected an ecr policy to be generated"
  }

  assert {
    condition     = length(tolist(aws_lambda_function_url.container_function_url)) == 0
    error_message = "expected no function url"
  }
}
