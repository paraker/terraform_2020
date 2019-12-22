# Storage module
Takes a project name and creates an S3 bucket with a random id trailing the name.
Outputs bucket name and bucket arn.

# Usage
    module "s3_bucket" {
      source = "./modules/storage"
      project_name = "${var.your_project_name}"
    }