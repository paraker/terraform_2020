resource "kubernetes_pod" "ghost_alpine" {
  # metadata - (Required) Standard pod's metadata. For more info see Kubernetes reference
  metadata {
    name = "ghost-alpine" # Sets the name of the pod
  }

  # spec (Required) Spec of the pod owned by the cluster
  spec {
    host_network = "true"  # Use the host's network namespace
    container {
      image = "ghost:alpine"  # Docker image name
      name  = "ghost-alpine"  # Container name for the pod (DNS_LABEL?)
    }
  }
}