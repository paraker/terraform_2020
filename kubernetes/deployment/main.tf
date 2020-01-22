resource "kubernetes_service" "ghost_service" {
  metadata {
    name = "ghost-service"
  }
  spec {
    # Selector determines where to route traffic
    selector {
      app = "${kubernetes_deployment.ghost_deployment.spec.0.template.0.metadata.0.labels.app}" # Interpolates deployment template's label "app"
    }
    port {
      port = "2368"  # list of container(?) ports that the service will expose
      target_port = "2368"  # port of the pod
      node_port = "8080"  # port on each kubernetes node, this is what we will connect to!
    }
    type = "NodePort"  # This is probably referring to that we want to use the host or LB port, i.e. in this case 8081.
  }
}

resource "kubernetes_deployment" "ghost_deployment" {
  metadata {
    name = "ghost-blog"
  }

  spec {
    replicas = "1"  # Number of pods that we want

    selector {
      match_labels {
        app = "ghost-blog"
      }
    }

    template {  # Template to create pods with
      metadata {
        labels {
          app = "ghost-blog"  # This is what we will use in our service to route traffic to
        }
      }

      spec {
        container {
          name  = "ghost"
          image = "ghost:alpine"
          port {
            container_port = "2368"
          }
        }
      }
    }
  }
}





#####################################################





resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "wordpress-mysql"
    labels = {
      app = "${var.app_label}"
    }
  }
  spec {
    selector {
      app  = "${var.app_label}"
      tier = "${var.mysql_tier}"
    }
    port {
      port = "3306"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "mysql_deployment" {
  metadata {
    name   = "wordpress-mysql"
    labels = {
      app = "${var.app_label}"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels {
        app  = "${var.app_label}"
        tier = "${var.mysql_tier}"
      }
    }

    template {
      metadata {
        labels {
          app  = "${var.app_label}"
          tier = "${var.mysql_tier}"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "${var.mysql_password}"
          }

          port {
            container_port = "3306"
            name           = "mysql"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress_service" {
  metadata {
    name   = "wordpress"
    labels = {
      app = "${var.app_label}"
    }
  }
  spec {
    selector {
      app  = "${var.app_label}"
      tier = "${var.wordpress_tier}"
    }

    port {
      port        = "80"
      target_port = "80"
      node_port   = "8081"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "wordpress_deployment" {
  metadata {
    name = "wordpress"
  }

  spec {
    replicas = "1"

    selector {
      match_labels {
        app  = "${var.app_label}"
        tier = "${var.wordpress_tier}"
      }
    }

    template {
      metadata {
        labels {
          app  = "${var.app_label}"
          tier = "${var.wordpress_tier}"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "wordpress:${var.wordpress_version}-apache"

          env {
            name = "WORDPRESS_DB_HOST"
            value = "wordpress-mysql"
          }

          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "${var.mysql_password}"
          }

          port {
            container_port = "80"
            name           = "wordpress"
          }
        }
      }
    }
  }
}