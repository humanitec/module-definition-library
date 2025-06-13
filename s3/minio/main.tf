terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
    }
  }
}

variable "provider_region" {
    type = string
}

variable "bucket_prefix" {
    type = string
    default = "bucket-"
}

resource "minio_s3_bucket" "bucket" {
  bucket_prefix = "${substr(replace(var.bucket_prefix, "[^a-z0-9\\-]+", "-"), 0, 36)}"
  force_destroy = true
}

output "arn" {
  value = minio_s3_bucket.bucket.arn
}

output "bucket" {
  value = minio_s3_bucket.bucket.bucket
}

output "region" {
  value = var.provider_region
}

output "endpoint" {
  value = minio_s3_bucket.bucket.bucket_domain_name
}
