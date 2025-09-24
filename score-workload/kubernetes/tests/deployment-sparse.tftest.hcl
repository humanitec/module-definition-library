mock_provider "kubernetes" {
}

mock_provider "random" {
}

run "plan" {
  variables {
    namespace = "default"

    metadata = {
      name = "deployment-sparse"
      annotations = {
        "score.humanitec.dev/workload-type" = "Deployment"
      }
    }

    containers = {
      "main" = {
        image = "nginx:latest"
      }
    }
  }

  assert {
    condition = kubernetes_deployment_v1.default[0].metadata[0].name == "deployment-sparse"
    error_message = "incorrect dep name"
  }

  assert {
    condition = length(kubernetes_stateful_set_v1.default) == 0
    error_message = "stateful set should not exist"
  }

  assert {
    condition = length(kubernetes_service_v1.default) == 0
    error_message = "incorrect service"
  }

  assert {
    condition = length(kubernetes_secret_v1.files) == 0
    error_message = "incorrect secret files: ${nonsensitive(jsonencode(kubernetes_secret_v1.files))}"
  }

  assert {
    condition = length(kubernetes_secret_v1.env) == 0
    error_message = "incorrect secret env: ${nonsensitive(jsonencode(kubernetes_secret_v1.env))}"
  }

  command = plan
}
