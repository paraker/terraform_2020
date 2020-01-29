variable "vpc_cidr" {
  default = "10.123.0.0/16"
}

variable "accessip" {
  default = "0.0.0.0/0"
}

# We will loop with the help of this variable
variable "service_ports" {
  default = ["22", "22"]  # List of ports that we will iterate over.
  # It's funny because the documentation says maps and sets are what you loop over with for_each. I suppose lists work as well.
}

# Normal creation of a vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf_vpc"
  }
}

# We will loop in this resouce's ingress block
resource "aws_security_group" "tf_public_sg" {
  name        = "tf_public_sg"
  description = "Used for access to the public instances"
  vpc_id      = aws_vpc.tf_vpc.id

  dynamic "ingress" {
    for_each = var.service_ports  # Defines our
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.accessip]
    }
  }
}