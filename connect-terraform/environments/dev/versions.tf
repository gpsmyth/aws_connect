terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/lambda_function.py"
  output_path = "${path.module}/lambda_src/lambda_function.zip"
}
