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

# Deploy Compute Resources
module "compute" {
  source          = "./modules/compute"
  instance_count  = "${var.instance_count}"
  key_name        = "${var.key_name}"
  public_key_path = "${var.public_key_path}"
  instance_type   = "${var.server_instance_type}"
  subnets         = "${module.networking.public_subnets}"
  security_group  = "${module.networking.public_sg}"
  subnet_ips      = "${module.networking.subnet_ips}"
}

resource "aws_s3_bucket" "state" {
  bucket = "terraform-state-paak-123456"
  acl = "private"
  tags {
    Name = "My state file for terraform course"
  }
}