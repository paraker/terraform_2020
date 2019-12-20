# Docker Swarm Services
Remember how we had to implement a little sleep hack after our mysql services were stood up?
Swarm is another approach to tackle that problem.

# Making the code swarm compatible
## Rewriting the network to span across multiple hosts
To use swarm services we need to change our network configuration from bridge to overlay.
Why is that so?
The reason is that a bridge network can only be used by a single host.
An overlay network on the other hand can span across multiple hosts, which suits swarm services!<br>
So we simply change from "bridge" to "overlay" as so:

    resource "docker_network" "public_bridge_network" {
      name = "public_ghost_network"
      driver = "overlay"
    }
    
    resource "docker_network" "private_bridge_network" {
      name = "ghost_mysql_internal"
      driver = "overlay"
      internal = "true"
    }

## Rewriting the individual containers to swarm services
With Swarm we are introduced to a new resource, docker_service.
The docker_service resource has a syntax which utilises three main components, task_spec, container_spec and endpoint spec. <br>
These can only be defined once within the docker_service resource block.

### task_spec - defines the desired state of the task 
The task spec should include information about the container specification and the network setup.<br>
The container spec is very similar to what we used before but the syntax is slightly different within this block.
As an example the environment parameters are passed in as a map rather than a list.<br>
Also the network portion looks slightly different.<br>
The volumes parameter also changes into a new block, I didn't include that in the code example, just look at the tf resource examples when setting up a service.

    resource "docker_service" "ghost_service" {
      name = "ghost"
    
      task_spec {
        container_spec {
          image = "${docker_image.ghost_image.name}"  # Yes we can use "latest" also!
          
          env = {
            database__client = "mysql"
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
      
  
### endpoint_spec - defines the load-balancer capabilities
The endpoint spec defines (among other things maybe?) the load-balancing capabilities or the network ports used by the docker_service we're defining.

      endpoint_spec {
        ports {
          target_port = "2368"
          published_port = "${var.ext_port}"
        }
      }

## Docker Swarm init
Notice that to run the services the docker host must be a swarm manager.
This is done by executing docker swarm init on a node.
Consecutive nodes can use docker swarm join --token <token> to join the swarm.

### Apply and show your swarm services
Run tf plan/apply as usual.

Run docker service ls to display the running services

    docker service ls

So where are the services running in the cluster? Good question, I hope we can find a command to show that.
At the moment all I have is the above service command.
For each individual host you can use the docker container ls, to show what's locally running.

## How did swarm help around the race condition?
That's unclear from the course material. And at the moment I don't have internet so I can't show the verification commands.
