mock_provider "kubernetes" {
}

mock_provider "random" {
}

run "plan" {
  variables {
    namespace = "default"

    metadata = {
      name = "statefulset-sparse"
      annotations = {
        "score.humanitec.dev/workload-type" = "StatefulSet"
      }
    }

    containers = {
      "main" = {
        image = "nginx:latest"
      }
    }
  }

  command = plan
}
