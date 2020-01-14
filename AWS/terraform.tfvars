# Supplies variables to variables.tf
# Root variables
aws_region = "us-east-1"

# Storage variables
project_name = "myproject"

# networking variables
vpc_cidr = "10.123.0.0/16"
public_cidrs = [
  "10.123.1.0/24",
  "10.123.2.0/24"
]
accessip = "0.0.0.0/0"
key_name = "linuxacademy_terraform.key"
public_key_path = "/Users/paak/.ssh/linuxacademy_terraform.key.pub"
server_instance_type = "t2.micro"
instance_count = 2