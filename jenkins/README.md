# Jenkins Pipelines

Jenkins
Create a custom jenkins image from jenkins:lts
Setup the environment:

    mkdir -p jenkins

Create Dockerfile:

    Vim Dockerfile
    FROM jenkins/jenkins:lts  # Fetch long term support image from dockerhub
    USER root # Change user to root for suod purposes (is by default jenkins as per the image)

    # Install various packages and docker
    RUN apt-get update -y && apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey
    RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
    RUN apt-get update -y
    RUN apt-get install -y docker-ce docker-ce-cli containerd.io

    # Download and install terraform
    RUN curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && unzip terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/

    # Set the user back to jenkins
    USER ${user}

Build the Image. Warning this takes quite a while.
    
    docker build -t jenkins:terraform .

List the Docker images:

    docker image ls
    REPOSITORY  TAG    IMAGE ID     CREATED             SIZE
    jenkins  terraform  9bbba16ad133   3 minutes ago   1.41GB

Deploy container from custom jenkins image, with container and host volumes
We'll create a main file and fill it with docker container and docker volume resources.
 Note how there is a special bind mount volume resource. This is to enable our jenkins container to be able to spin up other containers on the host.

Edit main.tf:
    vi main.tf

    main.tf contents:
    # Jenkins Volume
    resource "docker_volume" "jenkins_volume" {
      name = "jenkins_data"
    }

# Start the Jenkins Container
    resource "docker_container" "jenkins_container" {
      name  = "jenkins"
      image = "jenkins:terraform"
      ports {
        internal = "8080"
        external = "8080"
      }

    # This volume is only for the container itself. Standard stuff.
      volumes {
        volume_name    = "${docker_volume.jenkins_volume.name}"
        container_path = "/var/jenkins_home"
      }

    # This volume is mapped to the host! It's called a bind mount.
    # I think it will simply issue output to the /var/run/docker.sock service on the host rather than on the container.
    # Since we have Docker installed on the host hosting the container we can speak to the host's docker service from the container.
    # This is because we want the jenkins container to be able to spin up containers on the host rather than in the container. 
        
      volumes {
        host_path      = "/var/run/docker.sock"
        container_path = "/var/run/docker.sock"
      }
    }

Initialize Terraform:
    
    terraform init

Plan the deployment:

    terraform plan -out=tfplan

Deploy Jenkins:

    terraform apply tfplan

Get the Admin password.
    
    docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    2bb215df87144817ba464b9bfedaaf5c
Log on to the web console and create your jenkins admin user.
Connect to the public ip of your server on port 8080. Use the admin password and follow on screen instructions to configure an admin user.

# Create your first jenkins job
In the Jenkins dashboard, Click New Item.
Select Freestyle Project, and enter an item name of DeployGhost. Click Ok.
Under Source Code Management, select Git. Enter a Repository URL of https://github.com/linuxacademy/content-terraform-docker.git
In the Build section, click Add build step and select Execute shell from the dropdown.
Add the following in the Command area:

    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    docker container ls
    terraform destroy -auto-approve

Click Save.
Now, if we click Build Now in the left-hand menu, our project will start building. Clicking the little dropdown arrow next to #1 will give us a menu. Select Console Output to watch things build. Once we get a Finished: SUCCESS message, we're done.

# Create your first Jenkins pipeline
In the Jenkins dashboard, click New Item Enter an item name of PipelinePart1, and select Pipeline. Click Ok.
Check the box for This project is parameterized. Click Add Parameter and select Choice Parameter. Give it a Name of action. For Choices, enter Deploy and Destroy, and make sure they are on separate lines. Enter The action that will be executed as the Description.
Click Add Parameter and select Choice Parameter again. This time, name it image_name. Enter ghost:latest and ghost:alpine in the Choices box, making sure they are on separate lines. Enter The image Ghost Blog will deploy as a Description.
Click Add Parameter a third time, and select String Parameter. Give it a Name of ext_port. Set the Default Value to 80. Enter The Public Port as the Description.
Down in the Pipeline section, give a Definition of Pipeline script, and add the following to the Script:

    node {
      git 'https://github.com/linuxacademy/content-terraform-docker.git'
      if(action == 'Deploy') {
        stage('init') {
            sh """
                terraform init
            """
        }
        stage('plan') {
          sh label: 'terraform plan', script: "terraform plan -out=tfplan -input=false -var image_name=${image_name} -var ext_port=${ext_port}"
          script {
              timeout(time: 10, unit: 'MINUTES') {
                  input(id: "Deploy Gate", message: "Deploy environment?", ok: 'Deploy')
              }
          }
        }
        stage('apply') {
            sh label: 'terraform apply', script: "terraform apply -lock=false -input=false tfplan"
        }
      }
    
      if(action == 'Destroy') {
        stage('plan_destroy') {
          sh label: 'terraform plan destroy', script: "terraform plan -destroy -out=tfdestroyplan -input=false -var image_name=${image_name} -var ext_port=${ext_port}"
        }
        stage('destroy') {
          script {
              timeout(time: 10, unit: 'MINUTES') {
                  input(id: "Destroy Gate", message: "Destroy environment?", ok: 'Destroy')
              }
          }
          sh label: 'Destroy environment', script: "terraform apply -lock=false -input=false tfdestroyplan"
        }
      }
    }

Click Save

# Create your second pipeline
n the Jenkins dashboard, click New Item Enter an item name of PipelinePart2, and select Pipeline. Click Ok.
Check the box for This project is parameterized. Click Add Parameter and select Choice Parameter. Give it a Name of action. For Choices, enter Deploy and Destroy, and make sure they are on separate lines. Enter The action that will be executed as the Description.
Click Add Parameter and select Choice Parameter again. This time, name it image_name. Enter ghost:latest and ghost:alpine in the Choices box, making sure they are on separate lines. Enter The image Ghost Blog will deploy as a Description.
Click Add Parameter a third time, and select String Parameter. Give it a Name of ghost_ext_port. Set the Default Value to 80. Enter The Public Port as the Description.
Down in the Pipeline section, give a Definition of Pipeline script, and add the following to the Script:
    
    node {
      git 'https://github.com/linuxacademy/content-terraform-docker-service.git'
      if(action == 'Deploy') {
        stage('init') {
          sh label: 'terraform init', script: "terraform init"
        }
        stage('plan') {
          sh label: 'terraform plan', script: "terraform plan -out=tfplan -input=false -var image_name=${image_name} -var ghost_ext_port=${ghost_ext_port}"
          script {
              timeout(time: 10, unit: 'MINUTES') {
                input(id: "Deploy Gate", message: "Deploy environment?", ok: 'Deploy')
              }
          }
        }
        stage('apply') {
          sh label: 'terraform apply', script: "terraform apply -lock=false -input=false tfplan"
        }
      }
    
      if(action == 'Destroy') {
        stage('plan_destroy') {
          sh label: 'terraform plan', script: "terraform plan -destroy -out=tfdestroyplan -input=false -var image_name=${image_name} -var ghost_ext_port=${ghost_ext_port}"
        }
        stage('destroy') {
          script {
              timeout(time: 10, unit: 'MINUTES') {
                  input(id: "Destroy Gate", message: "Destroy environment?", ok: 'Destroy')
              }
          }
          sh label: 'terraform apply', script: "terraform apply -lock=false -input=false tfdestroyplan"
        }
        stage('cleanup') {
          sh label: 'cleanup', script: "rm -rf terraform.tfstat"
        }
      }
    }

# Create your third pipeline
In the Jenkins dashboard, click New Item Enter an item name of PipelinePart3, and select Pipeline. Click Ok.
Check the box for This project is parameterized. Click Add Parameter and select Choice Parameter. Give it a Name of action. For Choices, enter Deploy and Destroy, and make sure they are on separate lines. Enter The action that will be executed as the Description.
Click Add Parameter and select String Parameter. For the name, enter mysql_root_password.. Enter P4ssW0rd0! in the Default Value box. Enter MySQL root password. as a Description.
For the next parameter, click Add Parameter once more and select String Parameter. For the name, enter mysql_user_password.. Enter paSsw0rd0! in the Default Value box. Enter MySQL user password. as a Description.
Down in the Pipeline section, give a Definition of Pipeline script, and add the following to the Script:

    node {
      git 'https://github.com/linuxacademy/content-terraform-docker-secrets.git'
      if(action == 'Deploy') {
        stage('init') {
          sh label: 'terraform init', script: "terraform init"
        }
        stage('plan') {
          def ROOT_PASSWORD = sh (returnStdout: true, script: """echo ${mysql_root_password} | base64""").trim()
          def USER_PASSWORD = sh (returnStdout: true, script: """echo ${mysql_user_password} | base64""").trim()
          sh label: 'terraform plan', script: "terraform plan -out=tfplan -input=false -var mysql_root_password=${ROOT_PASSWORD} -var mysql_db_password=${USER_PASSWORD}"
          script {
              timeout(time: 10, unit: 'MINUTES') {
                  input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
              }
          }
        }
        stage('apply') {
          sh label: 'terraform apply', script: "terraform apply -lock=false -input=false tfplan"
        }
      }
    
      if(action == 'Destroy') {
        stage('plan_destroy') {
          def ROOT_PASSWORD = sh (returnStdout: true, script: """echo ${mysql_root_password} | base64""").trim()
          def USER_PASSWORD = sh (returnStdout: true, script: """echo ${mysql_user_password} | base64""").trim()
          sh label: 'terraform plan', script: "terraform plan -destroy -out=tfdestroyplan -input=false -var mysql_root_password=${ROOT_PASSWORD} -var mysql_db_password=${USER_PASSWORD}"
        }
        stage('destroy') {
          script {
              timeout(time: 10, unit: 'MINUTES') {
                  input(id: "Destroy Gate", message: "Destroy ${params.project_name}?", ok: 'Destroy')
              }
          }
          sh label: 'terraform apply', script: "terraform apply -lock=false -input=false tfdestroyplan"
        }
        stage('cleanup') {
          sh label: 'cleanup', script: "rm -rf terraform.tfstat"
        }
      }
    }

# Verification
The password apparently didn't work for me. Must've mistyped something.

    cloud_user@swarm-manager ~/terraform/terra_training $ docker exec -it 590e1531fa53 /bin/bash
    root@590e1531fa53:/#
    root@590e1531fa53:/#
    root@590e1531fa53:/# mysql -uroot -p
    Enter password:
    ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
