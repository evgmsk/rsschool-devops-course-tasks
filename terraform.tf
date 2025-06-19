terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  backend "s3" {
    bucket = "rs-terraform-c"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
