# Docker networking with blog and db

We will now set up a database for the ghost blog so that changes will be stored perpetually.
<br>
We will separate the frontend ghost blog from the backend db by putting them on separate networks.


We will work with bridge and overlay networks.
Overlay is mostly for docker swarm

This is how we create a bridge network for internal traffic
(as per the internal parameter set to true)
    
    resource "docker_network" "private_bridge_network" {
      name = "ghost_mysql_internal"
      driver = "bridge"
      internal = "true"
    }

And this is how we we assign a resource to use the private network.
We use a networks_advanced parameter for that    
    
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
      
# Troubleshooting container execution
So we started up our containers and one was indeed successful but the frontend wasn't.
How do we know?
Well for starters we can execute *docker container ls -a*. This shows us all containers, even the failed ones.

    networks docker container ls -a
    CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                            PORTS               NAMES
    d92e6f65b3aa        mysql:5.7           "docker-entrypoint.s…"   About a minute ago   Up About a minute                                     ghost_database
    ebb54e2fac1f        ghost:alpine        "docker-entrypoint.s…"   About a minute ago   Exited (255) About a minute ago                       ghost_blog
    edbedce151ac        fce289e99eb9        "/hello"                 5 hours ago          Exited (0) 5 hours ago                                hello-world-production
    a054ada62c85        hello-world         "/hello"                 16 hours ago         Exited (0) 16 hours ago                               flamboyant_benz
    654c3ae55d45        89ee3d485bdb        "/bin/sh -c 'apk -v …"   20 hours ago         Exited (1) 20 hours ago                               gifted_dewdney
    2219f3fb134e        hello-world         "/hello"                 20 hours ago         Exited (0) 20 hours ago                               frosty_brattain

The problem we had in our setup was that our mysql server wasn't ready at the time when the ghostblog wanted to use its services.
We solve this problem by doing two things:

1. First we move the mysql code before the ghost blog code.
I'm actually not sure if this has any impact whatsoever?

2. We introduce a null_resource with a sleep parameter and a depends_on parameter.
This will definitely have an effect. We also add a second depends_on parameter, this time in the ghost_blog resource.
This is a bit of a hack of course with 15 seconds sleep. It's not scientific


    resource "null_resource" "sleep" {
      depends_on = [docker_container.mysql_container]
      provisioner "local-exec" {
        command = "sleep 15s"
      }
    }
    
    resource "docker_container" "blog_container" {
      depends_on = [null_resource.sleep, docker_container.mysql_container]
      ...