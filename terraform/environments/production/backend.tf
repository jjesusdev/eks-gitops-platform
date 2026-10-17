terraform {
  backend "s3" {
    bucket         = "REEMPLAZAR_CON_BUCKET_DEL_BOOTSTRAP"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REEMPLAZAR_CON_TABLA_DEL_BOOTSTRAP"
    encrypt        = true
  }
}