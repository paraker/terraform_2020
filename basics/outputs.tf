output "docker_image_id" {
  value = "${module.image.image_id}"
}

output "docker_image_name" {
  value = "${module.image.image_out}"
}

output "container_ip" {
  value = "${module.container.ip}"
}

output "container_name" {
  value = "${module.container.container_name}"
}