variable "metadata" {
  type        = any
  description = "The metadata section of the Score file."
}

variable "containers" {
  type = object({
    main = object({
      image     = string
      command   = optional(list(string))
      args      = optional(list(string))
      variables = optional(map(string))
      resources = object({
        limits = object({
          memory = string
        })
      })
    })
  })
  description = "The containers section of the Score file, expecting just a single container called 'main'"

  validation {
    condition     = regex("^\\d+[MG]$", var.containers.main.resources.limits.memory) != null
    error_message = "memory limit must end in either M or G"
  }
}

variable "service" {
  type = object({
    ports = optional(map(object({
      port = number
    })))
  })
  description = "The service section of the Score file."
  default     = null
}

variable "iam_role_arn" {
  type        = string
  description = "An optional IAM role to run the function as. A simple role will be created if this is not supplied"
  default     = null
}

variable "architectures" {
  type        = list(string)
  description = "Set the AWS Lambda architectures supported by the image"
  default     = null
}

variable "region" {
  type        = string
  description = "Optional region override otherwise the function will be deployed in the same region as the provider"
  default     = null
}
