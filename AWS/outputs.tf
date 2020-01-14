#----root/outputs.tf-----

#----storage outputs-----
output "Bucket Name" {
  value = "${module.storage.bucketname}"
}

output "Bucket ARN" {
  value = "${module.storage.bucket_arn}"
}

#---Networking Outputs -----

output "Public Subnets" {
  # Threaded through from the networking module
  # join nicely puts the values in a comma separated list without line breaks.
  # If you don't use join it just prints the list in list syntax
  value = "${join(", ", module.networking.public_subnets)}"
}

output "Subnet IPs" {
  # Threaded through from the networking module
  # join nicely puts the values in a comma separated list without line breaks.
  # If you don't use join it just prints the list in list syntax
  value = "${join(", ", module.networking.subnet_ips)}"
}

output "Public Security Group" {
  value = "${module.networking.public_sg}"
}

#---Compute Outputs ------

output "Public Instance IDs" {
  value = "${module.compute.server_id}"
}

output "Public Instance IPs" {
  value = "${module.compute.server_ip}"
}