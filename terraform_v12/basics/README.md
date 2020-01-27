# Summary
Deploys docker image "hello-world locally" with terraform 0.12.<br>
If you have multiple versions of terraform installed, remember to use 0.12 to execute this code!

# Usage
Init and build

    terraform12 init
    terraform12 plan -out=tfplan  # Later I just got Error: Error pinging Docker server: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
    Plan: 3 to add, 0 to change, 0 to destroy.

    terraform12 apply  # This was actually run on tf 0.11... anyhow this is how it should work.
    Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
    
    # Test your hello world container
    docker run --name hello_world --rm -it hello-world

 destroy the environment.  
 
    terraform12 destroy  # Was actually run on 0.11...
    Plan: 0 to add, 0 to change, 2 to destroy.

    # We are getting errors here, not sure why.   # Was also run on 0.11 here.
    # The image
    3 errors occurred:
        * module.container.output.ip: variable "container_id" is nil, but no error was reported
        * module.image.docker_image.image_id (destroy): 1 error occurred:
        * docker_image.image_id: Unable to remove Docker image: Error: No such image: sha256:fce289e99eb9bca977dae136fbe2a82b6b7d4c372474c9235adc1741675f587e


        * module.container.output.container_name: variable "container_id" is nil, but no error was reported


# Terraform 12 Changes
## Interpolation syntax
Interpolation syntax has changed from ${} to HCL2.
    
    # 0.11
    value = "${docker_image.image_id.id}"

    # 0.12
    value = docker_image.image_id.id
    
## Variables types are not quoted anymore
Terraform 0.11 and earlier required type constraints to be given in quotes,
but that form is now deprecated and will be removed in a future version of
Terraform. To silence this warning, remove the quotes around "string".
    
    # 0.11
    variable "docker_image_name" {
      type = "string"
      default = "hello-world"
    }
    
    # 0.12
    variable "docker_image_name" {
    type = string
    default = "hello-world"
    }