mock_provider "kubernetes" {
    mock_data "kubernetes_secret_v1" {
      defaults = {
        metadata = {
        }
        data = {
          Key = "value"
        }
      }
    }
}

run "plan" {
  variables {
    namespace = "default"
    secret_name = "my-k8s-secret"
  }

  assert {
    condition = output.values.Key == "value"
    error_message = "incorrect data ${jsonencode(nonsensitive(output.values))}"
  }

  command = apply
}
