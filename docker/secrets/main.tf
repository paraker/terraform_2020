resource "docker_service" "mysql_service" {
  name = "${var.mysql_network_alias}"
  task_spec {
    container_spec {
      image = "${docker_image.mysql_image.name}"

      secrets = [
        {
          file_name = "/run/secrets/${docker_secret.mysql_root_password.name}"
          secret_id = "${docker_secret.mysql_root_password.id}"
          secret_name = "${docker_secret.mysql_root_password.name}"
        },
        {
          file_name = "/run/secrets/${docker_secret.mysql_db_password.name}"
          secret_id = "${docker_secret.mysql_db_password.id}"
          secret_name = "${docker_secret.mysql_db_password.name}"
        },
      ]

      env {
        MYSQL_ROOT_PASSWORD_FILE = "/run/secrets/${docker_secret.mysql_root_password.name}"
        MYSQL_DATABASE           = "mydb"
        MYSQL_PASSWORD_FILE      = "/run/secrets/${docker_secret.mysql_db_password.name}"
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




