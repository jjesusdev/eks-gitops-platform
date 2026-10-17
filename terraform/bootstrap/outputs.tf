output "s3_bucket_name" {
  description = "Nombre del bucket S3 para remote state"
  value       = aws_s3_bucket.tf_state.id
}

output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB para state locking"
  value       = aws_dynamodb_table.tf_locks.id
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.tf_state.arn
}