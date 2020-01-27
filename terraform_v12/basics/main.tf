module "image" {
  source = "./modules/image"
//  image_name = var.docker_image_name
  image_name = var.docker_image_name
}

module "container" {
  source = "./modules/container"
  container_name = "${var.container_name}-${lookup(var.environment, "pro")}"
  image = module.image.image_out  # referencing the output from the image module
  int_port = "80"
  ext_port = "80"
}

resource "docker_image" "myimage" {
  name = "hello-world"
}