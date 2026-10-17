output "github_actions_role_arn" {
  description = "ARN del rol que GitHub Actions asume"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Nombre del rol de GitHub Actions"
  value       = aws_iam_role.github_actions.name
}