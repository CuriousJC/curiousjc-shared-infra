# Starting main here

terraform {
  backend "s3" {
    bucket = "curiousjc-tf-state"
    key    = "curiousjc/curiousjc-shared-infra"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "curiousjc-shared-infra"
      terraform   = "true"
    }
  }
}
