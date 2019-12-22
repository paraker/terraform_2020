#----root/outputs.tf-----

#----storage outputs-----
output "Bucket Name" {
  value = "${module.storage.bucketname}"
}

output "Bucket ARN" {
  value = "${module.storage.bucket_arn}"
}

#----networking outputs----
output "public_subnets" {
  value = "${module.networking.public_subnets}"
}

output "public_sg" {
  value = "${module.networking.public_sg}"
}

output "subnet_ips" {
  value = "${module.networking.subnet_ips}"
}