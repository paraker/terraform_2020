#----networking/main.tf----

# Fetch available AZs from AWS
data "aws_availability_zones" "avaialble" {}

# Create VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "tf_vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "tf_internet_gateway" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
}

# Create public route table and route to internet gateway
resource "aws_route_table" "tf_public_rt" {
  vpc_id = "${aws_vpc.tf_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf_internet_gateway.id}"
  }

  tags {
    Name = "tf_public"
  }
}

# Create private route table, no route to internet gateway
resource "aws_route_table" "tf_private_rt" {
  vpc_id = "${aws_vpc.tf_vpc.id}"

  tags {
    Name = "tf_private"
  }
}

# Create multiple public subnets. Uses count to multiply resources
resource "aws_subnet" "tf_public_subnet" {
  count = 2
  vpc_id = "${aws_vpc.tf_vpc.id}"
  # public_cidrs is a list, index.count decides the index to use in the list
  cidr_block = "${var.public_cidrs[count.index]}"
  map_public_ip_on_launch = true  # Give a public ip and private ip to all containers in this subnet
  # avaialble.name is also a list, count sets index in the list
  availability_zone = "${data.aws_availability_zones.avaialble.names[count.index]}"

  tags {
    Name = "tf_public_${count.index + 1}"
    # Just a pure reference to the count, add 1 to get human friendly names
  }
}

