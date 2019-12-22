#----networking/main.tf----

# Fetch available AZs from AWS
data "aws_availability_zones" "available" {}

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
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "tf_public_${count.index + 1}"
    # Just a pure reference to the count, add 1 to get human friendly names
  }
}

resource "aws_route_table_association" "tf_public_assoc" {
  # Reference to previously defined count. So you match the same count value. DRY
  count = "${aws_subnet.tf_public_subnet.count}"

  # Reference to the counted subnet ids is done with *.id[count.index]
  # Translates to tf_public_subnet.0.id then tf_public_subnet.1.id
  subnet_id = "${aws_subnet.tf_public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.tf_public_rt.id}"
}

resource "aws_security_group" "tf_public_sg" {
  name = "tf_public_sg"
  description = "Used for access to the public instances"
  vpc_id = "${aws_vpc.tf_vpc.id}"

  # ingress SSH

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  # ingress HTTP

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  # egress - Permit all outbound traffic

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}