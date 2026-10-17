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
  description = "Ambiente"
  type        = string
}

variable "allowed_iam_arns" {
  description = "ARNs IAM con acceso a ECR"
  type        = list(string)
  default     = ["*"]
}