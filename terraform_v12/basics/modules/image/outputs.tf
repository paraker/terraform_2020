output "image_out" {
  value = docker_image.image_id.latest
}

output "image_id" {
  value = docker_image.image_id.id
}