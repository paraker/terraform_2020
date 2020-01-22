# Overview
Builds a `kubernetes_deployment` with ghost blog in it. <br>
A deployment can contain multiple pods.<br>
The deployment automatically re-deploys a pod if it is deleted!<br>
Builds a `kubernetes_service` that exposes the pod publicly.<br>


List the pods:

    kubectl get pods
 
List the deployment:

    kubectl get deployments

List the services:

    kubectl get services
   
Connect to the blog:

    visit the public IP address of the kubernetes cluster server on port 8081.
