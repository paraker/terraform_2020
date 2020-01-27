# Summary
Deploys docker image "hello-world locally" with terraform 0.12.
<br>
No code changes compared to 0.11 as far as I can remember.

# Usage
Init and build

    terraform init
    terraform plan -out=tfplan
    Plan: 3 to add, 0 to change, 0 to destroy.

    terraform apply
    Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
    
    # Test your hello world container
    docker run --name hello_world --rm -it hello-world

 destroy the environment.  
 
    terraform destroy
    Plan: 0 to add, 0 to change, 2 to destroy.

    # We are getting errors here, not sure why.
    # The image
    3 errors occurred:
        * module.container.output.ip: variable "container_id" is nil, but no error was reported
        * module.image.docker_image.image_id (destroy): 1 error occurred:
        * docker_image.image_id: Unable to remove Docker image: Error: No such image: sha256:fce289e99eb9bca977dae136fbe2a82b6b7d4c372474c9235adc1741675f587e


        * module.container.output.container_name: variable "container_id" is nil, but no error was reported
