# Usage

## Terraform Count - DRY - Don't Repeat Yourself
The count parameter on resources can simplify configurations and let you scale resources by simply incrementing a number.<br>
Starts with 0 and counts upwards. <br>
Can't be used on modules yet, perhaps in the future.<br>
Use count.index to interpolate the current iteration such as below.
    
    resource "aws_subnet" "tf_public_subnet" {
      count = 2
      vpc_id = "${aws_vpc.tf_vpc.id}"
      cidr_block = "${var.public_cidrs[count.index]}"  # public_cidrs is a list, index.count decides the index to use in the list
      map_public_ip_on_launch = true  # Give a public ip and private ip to all containers in this subnet
      availability_zone = "${data.aws_availability_zones.avaialble.names[count.index]}"  # Names is also a list, count sets index in the list
    
      tags {
        Name = "tf_public_${count.index + 1}"  # Just a pure reference to the count, add 1 to get human friendly names
      }

Examples found at: https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/count

## Terraform Data Sources
Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to build on information defined outside of Terraform, or defined by another separate Terraform configuration.

Providers are responsible in Terraform for defining and implementing data sources. Whereas a resource causes Terraform to create and manage a new infrastructure component, data sources present read-only views into pre-existing data, or they compute new values on the fly within Terraform itself.

For example, a data source may retrieve remote state data from a Terraform Cloud workspace, configuration information from Consul, or look up a pre-existing AWS resource by filtering on its attributes and tags.

Each data instance will export one or more attributes, which can be interpolated into other resources using variables of the form data.TYPE.NAME.ATTR.

Official documentation: https://www.terraform.io/docs/configuration-0-11/data-sources.html
