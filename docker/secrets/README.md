# Docker Secrets
Any information going into docker secrets needs to be base64 encoded.

We can generate base64 encoded strings very easily in bash:

    echo 'P4$$w0rd' | base64
    UDQkJHcwcmQK

## Start with base64 in your tf code
We will user base64 instead of our previous clear-text password/s in variables.tf.
This doesn't hide the password at all really. Excited to see what's to come.
OK so this doesn't do ANYTHING for having just base64 encoded password in version control.
It does probably store the passwords with more secure mechanisms in the container themselves though.
    
    variable "mysql_root_password" {
      default = "UDQkJHcwcmQK"  # Base64 encoding of "P4$$w0rd"
    }
    
    variable "mysql_db_password" {
      default = "UDQkJHcwcmQK"  # Base64 encoding of "P4$$w0rd"
    }

## secrets.tf file
We are now introduced to a new resource type in docker called docker_secret.
We use interpolation syntax to grab the base64 encoded variables we just created.
These resources are responsible for creating the secrets that our docker swarm services will consume.

    resource "docker_secret" "mysql_root_password" {
      name = "root_password"
      data = "${var.mysql_root_password}"
    }
    
    resource "docker_secret" "mysql_db_password" {
      name = "db_password"
      data = "${var.mysql_db_password}"
    }
    
## Configure docker swarm services to use secrets
### Specify the secret targets
In the task_spec block of a docker_service we have the container_spec block.
The container spec block lets us specify a secrets variable (a list of maps of secrets).
The secrets will be stored on disk in /run/secrets/ in the container. We will point to that location and file in the secrets block with the "file_name" key/value.
Note how this doesn't consume the secret, it just specifies it

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
  
### Consume the secrets with environment variables
We need to specify environment variables to consume the secrets that have been specified.
This is not super well explained why, I'm just guessing that the container needs them as environment variables rather.

      env {
        MYSQL_ROOT_PASSWORD_FILE = "/run/secrets/${docker_secret.mysql_root_password.name}"
        MYSQL_DATABASE           = "mydb"
        MYSQL_PASSWORD_FILE      = "/run/secrets/${docker_secret.mysql_db_password.name}"
      }
      
## Verify the secrets usage
We can verify by log in to the mysql container.
We need the container id to do that. Use docker container ls to find that value.

    docker container ls
This will give us the container id.

Then use docker container exec -it <container id> /bin/bash

    docker container exec -it <container id> /bin/bash
this will drop us into the prompt of the container

    mysql -uroot -p
Enter the unencrypted password to log in to the mysql service.

    \q 
To quit the mysql session.