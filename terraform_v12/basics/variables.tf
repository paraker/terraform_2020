variable "docker_image_name" {
  type = string
  default = "hello-world"
  description = "Name of my docker image"
}

variable "environment" {
  description = "environment selector"
  type = map
  default = {
    dev = "development"
    pro = "production"
  }
}

variable "container_name" {
  type = string
  default = "hello-world"
}

