#-----compute/outputs.tf-----

output "server_id" {
  # join nicely puts the values in a comma separated list without line breaks.
  # If you don't use join you get the same data, but with line breaks
  value = "${join(", ", aws_instance.tf_server.*.id)}"
}

output "server_ip" {
  # join nicely puts the values in a comma separated list without line breaks.
  # If you don't use join you get the same data, but with line breaks
  value = "${join(", ", aws_instance.tf_server.*.public_ip)}"
}