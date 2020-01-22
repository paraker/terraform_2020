resource "kubernetes_service" "ghost_service" {
  metadata {
    name = "ghost-service"
  }
  spec {
    # Selector says which pod to route traffic to
    selector {
      app = "${kubernetes_pod.ghost_alpine.metadata.0.labels.app}"  # Interpolate the pod's metadata. This will equal to "ghost-blog"
    }
    port {
      port = "2368"  # list of container(?) ports that the service will expose
      target_port = "2368"  # port of the pod
      node_port = "8081"  # port on each kubernetes node, this is what we will connect to!
    }
    type = "NodePort"  # This is probably referring to that we want to use the host or LB port, i.e. in this case 8081.
  }
}

resource "kubernetes_pod" "ghost_alpine" {
  metadata {
    name = "ghost-alpine"
    labels {
      app = "ghost-blog"
    }
  }

  spec {
    container {
      image = "ghost:alpine"
      name  = "ghost-alpine"
      port  {
        container_port = "2368"
      }
    }
  }
}