# Project overview
## [kubernetes]()
Deploys 

## [AWS]()
Deploys vpc, storage, compute to AWS. 

## Kubernetes
Deploys a ghost blog onto a locally running kubernetes cluster

## Basics
Deploys basic stuff to local docker.

## Jenkins
Creates a jenkins server from dockerhub.<br>
Builds a ci/cd pipeline in jenkins. Deploys ghost blog to docker.

# Terraform version 0.12
### Moving from 0.11 to 0.12
If you have copied code from a 0.11 directory, ensure you delete the .terraform directory and the tfstate files. <br>

    rm -rf .terraform terraform.tfstate

### Apply output changes in 0.12
In 0.12 a much shorter summary output is given from terraform apply.<br>
To see full resources output, run a terraform plan?
