output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR"
  value = {
    for name, repo in aws_ecr_repository.repos :
    name => repo.repository_url
  }
}

output "ecr_repository_names" {
  description = "Nombres de los repositorios ECR"
  value = [
    for name, repo in aws_ecr_repository.repos :
    repo.name
  ]
}

output "app_repository_url" {
  description = "URL del ECR repo de la aplicación principal"
  value       = aws_ecr_repository.repos["app"].repository_url
}