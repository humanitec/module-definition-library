mock_provider "kubernetes" {
}

mock_provider "random" {
}

run "plan" {
  variables {
    namespace = "default"
    replicas  = 1

    metadata = {
      name = "statefulset-full"
      annotations = {
        "score.humanitec.dev/workload-type" = "StatefulSet"
      }
    }

    containers = {
      "main" = {
        image = "nginx:latest"
        variables = {
          "MY_ENV_VAR" = "my-value"
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
        files = {
          "/mnt/test.txt" = {
            content = "hello world"
          }
          "/etc/other.txt" = {
            binaryContent = "Zml6emJ1enoK"
          }
        }
        livenessProbe = {
          httpGet = {
            path = "/"
            port = 80
          }
        }
        readinessProbe = {
          httpGet = {
            path = "/"
            port = 80
          }
        }
      }
    }

    service = {
      ports = {
        "http" = {
          port        = 80
          target_port = 80
        }
      }
    }
  }

  command = plan

  assert {
    condition = length(kubernetes_deployment_v1.default) == 0
    error_message = "deployment should not exist"
  }

  assert {
    condition = kubernetes_stateful_set_v1.default[0].metadata[0].name == "statefulset-full"
    error_message = "incorrect sset name"
  }

  assert {
    condition = kubernetes_service_v1.default[0].metadata[0].name == "statefulset-full"
    error_message = "incorrect service name"
  }

  assert {
    condition = length(kubernetes_secret_v1.files) == 2
    error_message = "incorrect secret files: ${nonsensitive(jsonencode(kubernetes_secret_v1.files))}"
  }

  assert {
    condition = kubernetes_secret_v1.files["main-eca5007265"].metadata[0].name == "statefulset-full-main-eca5007265"
    error_message = "incorrect secret name"
  }

  assert {
    condition = kubernetes_secret_v1.files["main-f74e1bb35d"].metadata[0].name == "statefulset-full-main-f74e1bb35d"
    error_message = "incorrect secret name"
  }

  assert {
    condition = length(kubernetes_secret_v1.env) == 1
    error_message = "incorrect secret env: ${nonsensitive(jsonencode(kubernetes_secret_v1.env))}"
  }

  assert {
    condition = kubernetes_secret_v1.env["main"].metadata[0].name == "statefulset-full-main-env"
    error_message = "incorrect secret env"
  }
}
