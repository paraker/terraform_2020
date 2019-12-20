resource "docker_service" "ghost_service" {
  name = "ghost"

  task_spec {
    container_spec {
      image = "${docker_image.ghost_image.name}"  # Yes we can use "latest" also!

      # Setting env, an optional resource parameter for docker container.
      # Takes key-value pairs to configure the container
      env = {
        database__client = "mysql"
        # No idea why we're using double underscore syntax here.
        database__connection__host = "${var.mysql_network_alias}"
        database__connection__user = "${var.ghost_db_username}"
        database__connection__password = "${var.mysql_root_password}"
        database__connection__database = "${var.ghost_db_name}"
      }
    }
   networks = [
      "${docker_network.public_overlay_network.name}",
      "${docker_network.public_overlay_network.name}"
    ]
  }

  endpoint_spec {
    ports {
      target_port = "2368"
      published_port = "${var.ext_port}"
    }

  }
}


resource "docker_service" "mysql_service" {
  name = "${var.mysql_network_alias}"
  task_spec {
    container_spec {
      image = "${docker_image.mysql_image.name}"
      env {
        MYSQL_ROOT_PASSWORD = "${var.mysql_root_password}"
      }
      mounts = [
        {
          target = "/var/lib/mysql"
          type = "volume"
          source = "${docker_volume.mysql_data_volume.name}"
        }
      ]
    }
    networks = [
      "${docker_network.private_overlay_network.name}"
    ]
  }

}




