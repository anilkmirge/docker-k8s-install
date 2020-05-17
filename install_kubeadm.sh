#!/bin/sh

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

echo 'Verifying the kubeadm version'
kubeadm version -o short 

echo 'Disabling swap in order for the kubelet to work properly.'
sudo swapoff -a
sudo kubeadm init --kubernetes-version $(kubeadm version -o short) --pod-network-cidr=192.168.0.0/16 | tee /tmp/kubeinit.log

echo 'To start using your cluster, running some more commands as a regular user'

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Then you can join any number of worker nodes by running the following on each as root:

# sudo kubeadm join 10.0.1.11:6443 --token 264t3t.rqy1qaf0dmfpeg5f 
# --discovery-token-ca-cert-hash sha256:68c340191ad5304bca36d3dd5570feb5bc2fbb29c8c1e389f1caa621b9e9c917

# Note: By default, tokens expire after 24 hours. If you are joining a node to the cluster after the current token has expired, you can create a new token by running the following command on the control-plane node:

# sudo kubeadm token create --print-join-command
# The output is similar to this:

# 5didvk.d09sbcov8ph2amjw

echo 'Deploying an Overlay POD Network'
echo 'Calico will automatically detect which IP address range to use for pod IPs based on the value provided via the --pod-network-cidr flag or via kubeadm’s configuration.'

kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

echo' Once a Pod network has been installed, you can confirm that it is working by checking that the CoreDNS Pod is Running in the output of kubectl get pods --all-namespaces.'

kubectl get pods --all-namespaces.