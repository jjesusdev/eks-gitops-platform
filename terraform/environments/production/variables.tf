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
  default     = "production"
}

# VPC
variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# EKS
variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "Tipos de instancia para nodos EKS"
  type        = list(string)
  default     = ["t3.xlarge"]
}

variable "node_min_size" {
  description = "Mínimo de nodos"
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Nodos deseados"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Máximo de nodos"
  type        = number
  default     = 6
}

variable "public_access_cidrs" {
  description = "CIDRs permitidos para API server público (restringir a oficina/VPN)"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# ECR
variable "allowed_iam_arns" {
  description = "ARNs IAM con acceso a ECR"
  type        = list(string)
  default     = ["*"]
}

# IAM / GitHub Actions
variable "github_org" {
  description = "Organización o usuario de GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio GitHub"
  type        = string
}

variable "github_branch" {
  description = "Rama principal"
  type        = string
  default     = "main"
}

# Backend (valores generados por terraform bootstrap)
variable "tfstate_bucket" {
  description = "Nombre del bucket S3 para remote state"
  type        = string
}

variable "tfstate_dynamodb_table" {
  description = "Nombre de la tabla DynamoDB para locking"
  type        = string
}