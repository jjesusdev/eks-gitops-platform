#!/bin/bash
set -euo pipefail

echo "=== EKS GitOps Platform Bootstrap ==="

for cmd in terraform aws kubectl docker; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd no está instalado"
    exit 1
  fi
done

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
PROJECT="eks-gitops"

cd terraform/bootstrap
cat > terraform.tfvars <<EOF
aws_region = "$AWS_REGION"
project    = "$PROJECT"
EOF
terraform init -input=false
terraform apply -auto-approve -input=false

BUCKET=$(terraform output -raw s3_bucket_name)
TABLE=$(terraform output -raw dynamodb_table_name)

cd ../../environments/staging
cat > backend.hcl <<EOF
bucket         = "$BUCKET"
key            = "staging/terraform.tfstate"
region         = "$AWS_REGION"
dynamodb_table = "$TABLE"
encrypt        = true
EOF
cat > terraform.tfvars <<EOF
aws_region             = "$AWS_REGION"
project                = "$PROJECT"
environment            = "staging"
github_org             = "TU_USUARIO_GITHUB"
github_repo            = "eks-gitops-platform"
tfstate_bucket         = "$BUCKET"
tfstate_dynamodb_table = "$TABLE"
EOF
terraform init -backend-config=backend.hcl -input=false
echo "=== Setup staging OK ==="

cd ../production
cat > backend.hcl <<EOF
bucket         = "$BUCKET"
key            = "production/terraform.tfstate"
region         = "$AWS_REGION"
dynamodb_table = "$TABLE"
encrypt        = true
EOF
cat > terraform.tfvars <<EOF
aws_region             = "$AWS_REGION"
project                = "$PROJECT"
environment            = "production"
github_org             = "TU_USUARIO_GITHUB"
github_repo            = "eks-gitops-platform"
tfstate_bucket         = "$BUCKET"
tfstate_dynamodb_table = "$TABLE"
EOF
terraform init -backend-config=backend.hcl -input=false
echo "=== Setup production OK ==="
echo "Ahora ejecuta: terraform plan && terraform apply en staging y production"