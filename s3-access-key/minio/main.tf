terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
    }
  }
}

resource "random_id" "id" {
  byte_length = 10
}

resource "minio_iam_user" "user" {
  name = "user-${random_id.id.hex}"
}

resource "minio_accesskey" "key" {
  user   = minio_iam_user.user.name
  status = "enabled"
}

# If you want to attach a policy to the user
resource "minio_iam_policy" "policy" {
  name = "policy-${random_id.id.hex}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::*"]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "binding" {
  user_name   = minio_iam_user.user.name
  policy_name = minio_iam_policy.policy.id
}

output "access_key_id" {
  value = minio_s3_bucket.key.access_key
}

output "secret_key" {
  value = minio_s3_bucket.key.secret_key
  sensitive = true
}
