# Overview
Creates:
* aws_key_pair (from existing key pair file)
* internet gateway
* private and public route tables
* private and public redundant subnets
* route table associations
* security groups

# Usage
    module "compute" {
      source       = "./modules/compute"

    }

Plan: 9 to add, 0 to change, 0 to destroy.

# Introduced concepts
## Template Provider
https://www.terraform.io/docs/providers/template/index.html
The template provider exposes data sources to use templates to generate strings for other Terraform resources or outputs<br>
We use it here to template ec2 builds.