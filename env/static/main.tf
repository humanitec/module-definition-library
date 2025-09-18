variable "values" {
  type = map(string)
}

output "values" {
  value     = var.values
  sensitive = true
}
