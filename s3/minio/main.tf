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
    default = "bucket"
}

resource "minio_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
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
