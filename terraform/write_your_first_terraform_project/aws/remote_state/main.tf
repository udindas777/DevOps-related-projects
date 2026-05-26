#RAFORM REMOTE BACKEND SETUP (S3 + DYNAMODB)
# ==========================================================================================================
# PURPOSE:
# This Terraform configuration creates the backend infrastructure required
# to store Terraform state remotely for the "demo EC2 project".
#
# COMPONENTS CREATED:
# 1. S3 Bucket      → Stores Terraform state files (.tfstate)
# 2. DynamoDB Table → Provides state locking to avoid conflicts
#
# USAGE:
# This backend will later be used by other Terraform projects using:
#
# terraform {
#   backend "s3" {
#     bucket         = "terraform-demo-state-<account-id>"
#     key            = "demo/terraform.tfstate"
#     region         = "ap-south-2"
#     dynamodb_table = "terraform-demo-lock"
#     encrypt        = true
#   }
# }
# ==========================================================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
}

# -------------------------------
# AWS PROVIDER CONFIGURATION
# -------------------------------
provider "aws" {
  region = "ap-south-2"
}

# -------------------------------
# GET AWS ACCOUNT ID
# Used to make bucket name globally unique
# -------------------------------
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# -------------------------------
# S3 BUCKET (TERRAFORM STATE STORAGE)
# -------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-demo-state-${local.account_id}"

  tags = {
    Name        = "terraform-demo-state-bucket"
    Environment = "dev"
    Purpose     = "Stores Terraform state files for EC2 demo project"
  }
}

# Enable versioning (important for state history)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption (security best practice)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------
# DYNAMODB TABLE (STATE LOCKING)
# -------------------------------
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-demo-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-demo-lock-table"
    Purpose     = "Prevents concurrent Terraform state changes"
    Environment = "dev"
  }
}
