# General
This is in principle a subet of the same projects as the 0.11 terraform code one level up.<br>
Changes are described below and in each of the individual project readmes
# Terraform 0.12 Updates
## Expressions
See "loops" section

## Functions
See "functions" section

## interpolation replaced with [format function](https://www.terraform.io/docs/configuration/functions/format.html)
The specification is a string that includes formatting verbs that are introduced with the % character. <br>
The function call must then have one additional argument for each verb sequence in the specification.<br>
The verbs are matched with consecutive arguments and formatted as directed, as long as each given argument is convertible to the type required by the format verb.<br>
<br>
%d means Convert to integer number and produce decimal representation.<br>
Convert to string and insert the string's characters.<br>
See full list of verbs at [terraform docs](https://www.terraform.io/docs/configuration/functions/format.html)

    # 0.11
    resource "aws_s3_bucket" "tf_code" {
        bucket        = "${var.project_name}-${random_id.tf_bucket_id.dec}"

    # 0.12
    resource "aws_s3_bucket" "tf_code" {
        bucket        = format("%s-%d", var.project_name, random_id.tf_bucket_id.dec)
        
## resource tags
resource tag syntax changed from straight open map to "= map".
    
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
## Applies are abbreviated, plans are the same
terraform apply will now only give a couple of summary lines of output. Full details are shown in terraform plan.
