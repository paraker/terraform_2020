#----root/outputs.tf-----

#----storage outputs-----
output "Bucket Name" {
  value = "${module.storage.bucketname}"
}

output "Bucket ARN" {
  value = "${module.storage.bucket_arn}"
}