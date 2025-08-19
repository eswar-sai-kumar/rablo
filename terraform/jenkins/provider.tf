terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "s3bucket-project-devops"
    key    = "jenkins"
    region = "us-east-1"
    use_lockfile = true
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}