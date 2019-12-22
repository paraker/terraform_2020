# Supplies variables to variables.tf
# Root variables
aws_region = "us-east-1"

# Storage variables
project_name = "myproject"

# netowrking variables
vpc_cidr = "10.123.0.0/16"
public_cidrs = [
  "10.123.1.0/24",
  "10.123.2.0/24"
]
accessip = "0.0.0.0/0"