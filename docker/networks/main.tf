resource "docker_container" "mysql_container" {
  image = "${docker_image.mysql_image.name}"
  name = "ghost_database"

  # Utilising env variables again to configure the container
  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}"
  ]

  networks_advanced {
    name = "${docker_network.private_bridge_network.name}"
    aliases = ["${var.mysql_network_alias}"]
  }
}

resource "null_resource" "sleep" {
  depends_on = ["docker_container.mysql_container"]
  provisioner "local-exec" {
    command = "sleep 15s"
  }
}

resource "docker_container" "blog_container" {
  depends_on = ["null_resource.sleep", "docker_container.mysql_container"]
  image = "${docker_image.ghost_image.name}"  # Yes we can use "latest also!
  name = "ghost_blog"

  # Setting env, an optional resource parameter for docker container.
  # Takes key-value pairs to configure the container
  env = [
    "database__client=mysql",  # No idea why we're using double underscore syntax here.
    "database__connection__host=${var.mysql_network_alias}",
    "database__connection__user=${var.ghost_db_username}",
    "database__connection__password=${var.mysql_root_password}",
    "database__connection__database=${var.ghost_db_name}"
  ]

  ports {
    internal = "2368"
    external = "${var.ext_port}"
  }

  networks_advanced {
    name = "${docker_network.public_bridge_network.name}"
    aliases = ["${var.ghost_network_alias}"]
  }
  networks_advanced {
    name = "${docker_network.private_bridge_network.name}"
    aliases = ["${var.ghost_network_alias}"]
  }
}

