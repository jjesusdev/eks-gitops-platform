terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# OIDC provider para GitHub Actions (si no existe en la cuenta)
# Nota: GitHub usa el proveedor OIDC de AWS IAM
# Se asume que el provider ya existe en la cuenta; si no, crearlo manualmente:
# aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com --thumbprint-list <thumbprint>

# Rol que GitHub Actions asume para operar en AWS
resource "aws_iam_role" "github_actions" {
  name = "${var.project}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-github-actions-role"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Policy: acceso a EKS (kubectl, helm)
resource "aws_iam_policy" "github_actions_eks" {
  name        = "${var.project}-${var.environment}-github-actions-eks"
  description = "Permite a GitHub Actions gestionar recursos EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
        ]
        Resource = var.eks_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:CreateAddon",
          "eks:DeleteAddon",
          "eks:UpdateAddon",
        ]
        Resource = var.eks_cluster_arn
        Resource = "${var.eks_cluster_arn}/*"
      }
    ]
  })
}

# Policy: acceso a ECR (push/pull imágenes)
resource "aws_iam_policy" "github_actions_ecr" {
  name        = "${var.project}-${var.environment}-github-actions-ecr"
  description = "Permite a GitHub Actions push/pull en ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:ListImages",
        ]
        Resource = var.ecr_repository_arns
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy: Terraform apply (S3 + DynamoDB)
resource "aws_iam_policy" "github_actions_tf" {
  name        = "${var.project}-${var.environment}-github-actions-tf"
  description = "Permite a GitHub Actions ejecutar Terraform en este proyecto"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",
        ]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Attach policies al rol
resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks.arn
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

resource "aws_iam_role_policy_attachment" "tf" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_tf.arn
}