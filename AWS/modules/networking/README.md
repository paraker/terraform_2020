# Overview
Creates:
* vpc
* internet gateway
* private and public route tables
* private and public redundant subnets
* route table associations
* security groups

# Usage
    module "networking" {
      source       = "./modules/networking"
      vpc_cidr     = "${var.<vpc cidr range>}"
      public_cidrs = "${var.<public cidrs>}"
      accessip     = "${var.<IPs to get access to your public services>}" 
    }

Plan: 9 to add, 0 to change, 0 to destroy.

# Introduced concepts
## Terraform Count - DRY - Don't Repeat Yourself
The count parameter on resources can simplify configurations and let you scale resources by simply incrementing a number.<br>
Starts with 0 and counts upwards. <br>
Can't be used on modules yet, perhaps in the future.<br>
Use count.index to interpolate the current iteration such as below.
    
    resource "aws_subnet" "tf_public_subnet" {
      count = 2
      vpc_id = "${aws_vpc.tf_vpc.id}"
      
      # public_cidrs is a list, index.count decides the index to use in the list
      cidr_block = "${var.public_cidrs[count.index]}"
      
      # Give a public ip and private ip to all containers in this subnet
      map_public_ip_on_launch = true
      
      # Names is also a list, count sets index in the list
      availability_zone = "${data.aws_availability_zones.avaialble.names[count.index]}"
    
      tags {
        # Just a pure reference to the count, add 1 to get human friendly names
        Name = "tf_public_${count.index + 1}"
      }
      
To masterfully match the count variables in other resources we can interpolate the count definition.<br>
The syntax to refer to counted resources has a special * syntax, see below example

    resource "aws_route_table_association" "tf_public_assoc" { 
      # Reference to previously defined count. So you match the same count value. DRY
      count = "${aws_subnet.tf_public_subnet.count}"
      
      # Reference to the counted subnet ids is done with *.id[count.index]
      # Translates to tf_public_subnet.0.id then tf_public_subnet.1.id
      subnet_id = "${aws_subnet.tf_public_subnet.*.id[count.index]}"
      route_table_id = "${aws_route_table.tf_public_rt.id}"
    }
    
The same approach iteration * syntax is used for outputs when dealing with counted resources.

    # Use count iteration for the counted resource "tf_public_subnet"
    # to get all subnets cidr_blocks one output block
    output "subnet_ips" {
      value = "${aws_subnet.tf_public_subnet.*.cidr_block}"
    }

Examples found at: https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/count

## Terraform Data Sources
Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to build on information defined outside of Terraform, or defined by another separate Terraform configuration.

Providers are responsible in Terraform for defining and implementing data sources. Whereas a resource causes Terraform to create and manage a new infrastructure component, data sources present read-only views into pre-existing data, or they compute new values on the fly within Terraform itself.

For example, a data source may retrieve remote state data from a Terraform Cloud workspace, configuration information from Consul, or look up a pre-existing AWS resource by filtering on its attributes and tags.

Each data instance will export one or more attributes, which can be interpolated into other resources using variables of the form data.TYPE.NAME.ATTR.

    # declaration
    data "aws_availability_zones" "available" {}
    
    # interpolation
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"


Official documentation: https://www.terraform.io/docs/configuration-0-11/data-sources.html
