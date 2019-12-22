#----networking/variables.tf----
variable "vpc_cidr" {
  description = "Over-arching RFC1918 for our VPC"
}

variable "public_cidrs" {
  type = "list"
  description = "list of public cidr blocks picked from our vpc cidr range"
}

variable "accessip" {
  description = "IP range that will have access to our public subnets"
}