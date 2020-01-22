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
      node_port = "8081"  # port on each kubernetes node, this is what we will connect to!
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