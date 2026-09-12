terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37.0"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region  = var.aws_region
  profile = "ansible-aws-lab"
}