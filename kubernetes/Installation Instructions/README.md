# Installation instructions
# Create a cloudnative kubernetes server 
Create it through the linuxacademy playground.
Log on to the server. It has kubernetes pre-installed.

# Configure kubernetes
Add the following to kube-config.yml. <br>
Check the latest kubernetes version at [release notes](https://kubernetes.io/docs/setup/release/notes/)<br>
Add that version in the kubernetesVersion field below, obviously. 

    apiVersion: kubeadm.k8s.io/v1beta1
    kind: ClusterConfiguration
    kubernetesVersion: "v1.16.3"
    networking:
      podSubnet: 10.244.0.0/16
    apiServer:
      extraArgs:
        service-node-port-range: 8000-31274

Initialize Kubernetes from your newly created file

    sudo kubeadm init --config kube-config.yml

Copy default admin.conf from /etc/kubernetes/ to your home directory

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

Install Flannel. No idea what this does.

    sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

Untaint the Kubernetes Master. After this we can run pods on it.

    kubectl taint nodes --all node-role.kubernetes.io/master-