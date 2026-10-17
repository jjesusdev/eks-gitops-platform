variable "aws_region" {
  description = "AWS region para todos los recursos"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Nombre del proyecto, usado como prefijo en recursos"
  type        = string
  default     = "eks-gitops"
}