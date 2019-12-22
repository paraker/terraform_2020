#----root/main.tf-----
provider "aws" {
  region = "${var.aws_region}"
}

# Deploy storage resources
module "storage" {
  source = "./modules/storage"
  project_name = "${var.project_name}"
}