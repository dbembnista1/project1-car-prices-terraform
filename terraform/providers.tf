terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "terraform-sub"

  assume_role {
    role_arn = "arn:aws:iam::706762893183:role/TerraformExecutionRole"
  }
}