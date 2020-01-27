# Storage module
Takes a project name and creates an S3 bucket with a random id trailing the name.
Outputs bucket name and bucket arn.

# Usage
    module "s3_bucket" {
      source = "./modules/storage"
      project_name = "${var.your_project_name}"
    }

# Terraform 0.12 Updates
## S3 resource tags
S3 resource tag syntax changed from straight open map to "= map".
    
    # 0.11
    tags {
      Name = "tf_bucket"
    }
    
    # 0.12
    tags =  {
      Name = "tf_bucket"
    }
    
## Interpolation syntax
Interpolation syntax has changed from ${} to HCL2.
    
    # 0.11
    value = "${docker_image.image_id.id}"

    # 0.12
    value = docker_image.image_id.id
    
## Variables types are not quoted anymore
Terraform 0.11 and earlier required type constraints to be given in quotes,
but that form is now deprecated and will be removed in a future version of
Terraform. To silence this warning, remove the quotes around "string".
    
    # 0.11
    variable "docker_image_name" {
      type = "string"
      default = "hello-world"
    }
    
    # 0.12
    variable "docker_image_name" {
    type = string
    default = "hello-world"
    }