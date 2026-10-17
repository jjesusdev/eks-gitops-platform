variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "eks-gitops"
}

variable "environment" {
  description = "Ambiente (staging | production)"
  type        = string
}

variable "github_org" {
  description = "Organización o usuario de GitHub"
  type        = string
  default     = "tu-usuario-github"
}

variable "github_repo" {
  description = "Nombre del repositorio en GitHub"
  type        = string
  default     = "eks-gitops-platform"
}

variable "github_branch" {
  description = "Rama principal del repositorio"
  type        = string
  default     = "main"
}

variable "eks_cluster_arn" {
  description = "ARN del cluster EKS"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ARNs de los repositorios ECR"
  type        = list(string)
  default     = ["*"]
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3 de Terraform state"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB para locks"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS (si aplica)"
  type        = string
  default     = "*"
}