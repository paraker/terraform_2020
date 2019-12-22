#----root/main.tf-----
provider "aws" {
  region = "${var.aws_region}"
}

# Deploy storage resources
module "storage" {
  source       = "./modules/storage"
  project_name = "${var.project_name}"
}

# Deploy networking resources
module "networking" {
  source       = "./modules/networking"
  vpc_cidr     = "${var.vpc_cidr}"
  public_cidrs = "${var.public_cidrs}"
  accessip     = "${var.accessip}"
}