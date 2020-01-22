# Overview
Deploys a ghost blog onto a locally running kubernetes cluster with terraform

# Define and auth k8s cluster
Cluster is specified in `~/.kube/config` <br>
Target cluster is set by:

    clusters:
    - cluster:
        server: https://172.31.41.239:6443
       
Credentials are also set in this file. I think the certificate is used for auth?


## pod
Just the pod, no access to the blog

## service
The same pod with the blog. Also a service that exposes network ports.

## deployment