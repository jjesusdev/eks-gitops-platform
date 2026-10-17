terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "eks-gitops-tfstate-${var.project}-${data.aws_caller_identity.current.account_id}-${random_pet.suffix.id}"

  tags = {
    Name      = "eks-gitops-tfstate"
    Project   = var.project
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "eks-gitops-tflocks-${var.project}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "eks-gitops-tflocks"
    Project   = var.project
    ManagedBy = "terraform"
  }
}

data "aws_caller_identity" "current" {}