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

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para EKS"
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "Tipos de instancia EC2 para nodos"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Tamaño mínimo del node group"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Tamaño deseado del node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Tamaño máximo del node group"
  type        = number
  default     = 5
}

variable "public_access_cidrs" {
  description = "CIDRs permitidos para acceso público al API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_service_account_role" {
  description = "Crear IAM Role genérico para Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "k8s_namespace" {
  description = "Namespace para el service account"
  type        = string
  default     = "default"
}

variable "k8s_service_account_name" {
  description = "Nombre del service account"
  type        = string
  default     = "default"
}