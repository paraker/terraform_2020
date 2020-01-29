variable "vpc_cidr" {
  default = "10.123.0.0/16"
}

variable "accessip" {
  default = "0.0.0.0/0"
}

# We will loop with the help of this variable
variable "service_ports" {
  default = ["22", "80", "8080"]  # List of ports that we will iterate over.
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

  dynamic "ingress" { # Defines a dynamic block that we can iterate over
    for_each = var.service_ports  # Defines our complex variable to iterate over
    iterator = network_ports  # Defines an iterator, i.e. a reference to our variable we can iterate over
    content {  # Content block that will be repeated for each variable we can iterate over
      from_port   = network_ports.value  # We use the value from our iterator, this will be 22, then 80, then 8080
      to_port     = network_ports.value  # We use the value from our iterator, this will be 22, then 80, then 8080
      protocol    = "tcp"
      cidr_blocks = [var.accessip]
    }
  }
}


# More advanced looping over a list of maps
variable "service_ports_list_of_maps" {
  default = [
    {
      from_port = "22",
      to_port   = "22"
    },
    {
      from_port = "80",
      to_port   = "80"
    }
  ]
}

resource "aws_security_group" "tf_public_sg_list_of_maps" {
  name        = "tf_public_sg_list_of_maps"
  description = "Used for access to the public instances"
  vpc_id      = aws_vpc.tf_vpc.id

  dynamic "ingress" {  # Defines a dynamic block that we can iterate over
    for_each = [ for port in var.service_ports_list_of_maps: {  # for loop is initiated, "port" is set to each respective element in the list of maps
      from_port = port.from_port
      to_port = port.to_port
    }]  # the [] indicate that a tuple will be generated.
    iterator = network_ports  # Defines an iterator, i.e. a reference to our variable we can iterate over

    content {
      from_port   = network_ports.value.from_port  # Grabs the from_port value from our iterator. Will be 22, then 80
      to_port     = network_ports.value.to_port    # Grabs the to_port value from our iterator. Will be 22, then 80
      protocol    = "tcp"
      cidr_blocks = [var.accessip]
    }
  }
}

output "ingress_port_mapping" {
  value = {
    for ingress in aws_security_group.tf_public_sg_list_of_maps.ingress:  # for loop is initiated, "ingress" is set to each respective element of the dynamic block "ingress"
    format("From %d", ingress.from_port) => format("To %d", ingress.to_port)  # outputs the values of ingress' ports, will first be 22,22 then 80,80
  }
}