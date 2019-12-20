resource "docker_container" "container_id" {
  image = "${var.image}"
  name = "${var.container_name}"
  ports {
    internal = "${var.int_port}"
    external = "${var.ext_port}"
  }
}