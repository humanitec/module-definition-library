variable "values" {
    type = object(string)
}

output "values" {
    value = var.values
    sensitive = true
}
