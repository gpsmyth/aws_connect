provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "connect-terraform"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}