variable "vpc_cidr" {
  default = "10.123.0.0/16"
}

variable "accessip" {
  default = "0.0.0.0/0"
}

# This list is what we will be iterating with
variable "subnet_numbers" {
  default = [1, 2, 3]
}

resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_security_group" "tf_public_sg" {
  name        = "tf_public_sg"
  description = "Used for access to the public instances"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [
      for num in var.subnet_numbers:  # for loop with elements from var.subnet_numbers in "num"
      cidrsubnet(aws_vpc.tf_vpc.cidr_block, 8, num)  # loops out cidrsubnet(10.123.0.0/16, 8, 1) then cidrsubnet(10.123.0.0/16, 8, 2), then cidrsubnet(10.123.0.0/16, 8, 3)
      # the built-in cidrsubnet function will generate 10.123.1.0/24, 10.123.2.0/24, 10.123.3.0/24 from that input.
    ]
  }
}