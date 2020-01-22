terraform {
  backend "s3" {
    key = "terraform-aws/terraform.tfstate"
  }
}

# Initialise terraform with:
# terraform init -backend-config "bucket=terraform-state-paak-123456"
# This seems to work even without the bucket existing to start with. Fantastic.