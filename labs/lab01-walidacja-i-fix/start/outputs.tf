output "bucket_name" {
  description = "Nazwa bucketu z logami"
  value       = aws_s3_bucket.logi.id
}

output "role_arn" {
  description = "ARN roli kolektora"
  value       = aws_iam_role.kolektor.arn
}
