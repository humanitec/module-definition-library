terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
    }
  }
}

variable "ips" {
  type = list(string)
}

variable "ssh_user" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "metadata" {
  type        = any
  description = "The metadata section of the Score file."
}

variable "containers" {
  type = map(object({
    image = string
    command = optional(list(string))
    args = optional(list(string))
    variables = optional(map(string))
    files = optional(map(object({
      source = optional(string)
      content = optional(string)
      binaryContent = optional(string)
      mode = optional(string)
      noExpand = optional(bool)
    })))
    volumes = optional(map(object({
      source = string
      path = optional(string)
      readOnly = optional(bool)
    })))
    resources = optional(object({
      limits = optional(object({
        memory = optional(string)
        cpu = optional(string)
      }))
      requests = optional(object({
        memory = optional(string)
        cpu = optional(string)
      }))
    }))
    livenessProbe = optional(object({
      httpGet = optional(object({
        host = optional(string)
        scheme = optional(string)
        path = string
        port = number
        httpHeaders = optional(list(object({
          name = string
          value = string
        })))
      }))
      exec = optional(object({
        command = list(string)
      }))
    }))
    readinessProbe = optional(object({
      httpGet = optional(object({
        host = optional(string)
        scheme = optional(string)
        path = string
        port = number
        httpHeaders = optional(list(object({
          name = string
          value = string
        })))
      }))
      exec = optional(object({
        command = list(string)
      }))
    }))
  }))
  description = "The containers section of the Score file."
}

variable "service" {
  type = object({
    ports = optional(map(object({
      port = number
      protocol = optional(string)
      targetPort = optional(number)
    })))
  })
  description = "The service section of the Score file."
  default     = null
}

resource "null_resource" "install_ansible" {
  provisioner "local-exec" {
    command = "apk add --no-cache ansible-core"
  }
  triggers = {
    always_run = timestamp()  # Runs every apply
  }
}

resource "ansible_host" "target_hosts" {
  count = length(var.ips)
  
  name   = "host-${count.index + 1}"
  groups = ["targets"]
  
  variables = {
    ansible_host                 = var.ips[count.index]
    ansible_user                = var.ssh_user
    ansible_ssh_private_key = var.ssh_private_key
    ansible_ssh_common_args     = "-o StrictHostKeyChecking=no"
  }
}
