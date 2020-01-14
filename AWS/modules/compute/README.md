# Overview
Creates:
* aws_key_pair (from existing key pair file)
* internet gateway
* private and public route tables
* private and public redundant subnets
* route table associations
* security groups

# Usage
NOTE: Requires network module to work as we are referencing subnets, sgs and ips from there.

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

Plan: 4 to add, 0 to change, 0 to destroy.

# Introduced concepts
## Template Provider
https://www.terraform.io/docs/providers/template/index.html
The template provider exposes data sources to use templates to generate strings for other Terraform resources or outputs<br>
We use it here to template ec2 builds.

Attribute References:
template - See Argument Reference above.
vars - See Argument Reference above.
rendered - The final rendered template - we will use this in our code 

## Element
https://www.terraform.io/docs/configuration-0-11/interpolation.html
Returns a single element from a list at the given index. If the index is greater than the number of elements, this function will wrap using a standard mod algorithm. This function only works on flat lists. Examples:

    element(aws_subnet.foo.*.id, count.index)
    element(var.list_of_strings, 2)

## join
https://www.terraform.io/docs/configuration-0-11/interpolation.html
join(delim, list) - Joins the list with the delimiter for a resultant string. This function works only on flat lists. Examples:

    join(",", aws_instance.foo.*.id)
    join(",", var.ami_list)
