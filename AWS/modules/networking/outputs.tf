#----networking/output.tf----

# Use count iteration for the counted resource "tf_public_subnet"
# to get all subnets ids in one output block
output "public_subnets" {
  value = "${aws_subnet.tf_public_subnet.*.id}"
}

output "public_sg" {
  value = "${aws_security_group.tf_public_sg.id}"
}

# Use count iteration for the counted resource "tf_public_subnet"
# to get all subnets cidr_blocks one output block
output "subnet_ips" {
  value = "${aws_subnet.tf_public_subnet.*.cidr_block}"
}