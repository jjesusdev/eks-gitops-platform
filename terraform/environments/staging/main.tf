locals {
  aws_region  = "us-east-1"
  project     = "eks-gitops"
  environment = "staging"
}

module "vpc" {
  source             = "../../modules/vpc"
  aws_region         = local.aws_region
  project            = local.project
  environment        = local.environment
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = true
  enable_flow_logs   = false
}

module "eks" {
  source                      = "../../modules/eks"
  aws_region                  = local.aws_region
  project                     = local.project
  environment                 = local.environment
  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnet_ids
  kubernetes_version          = var.kubernetes_version
  node_instance_types         = var.node_instance_types
  node_min_size               = var.node_min_size
  node_desired_size           = var.node_desired_size
  node_max_size               = var.node_max_size
  public_access_cidrs         = var.public_access_cidrs
  create_service_account_role = false
}

module "ecr" {
  source           = "../../modules/ecr"
  aws_region       = local.aws_region
  project          = local.project
  environment      = local.environment
  allowed_iam_arns = var.allowed_iam_arns
}

module "iam" {
  source              = "../../modules/iam"
  aws_region          = local.aws_region
  project             = local.project
  environment         = local.environment
  github_org          = var.github_org
  github_repo         = var.github_repo
  github_branch       = var.github_branch
  eks_cluster_arn     = module.eks.cluster_arn
  ecr_repository_arns = module.ecr.ecr_repository_urls
  s3_bucket_arn       = "arn:aws:s3:::${var.tfstate_bucket}"
  dynamodb_table_arn  = "arn:aws:dynamodb:${local.aws_region}::table/${var.tfstate_dynamodb_table}"
}