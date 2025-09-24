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

  command = plan
}
