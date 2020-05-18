#!/bin/bash

echo 'ALERT:: Make sure you call this script as sudo. For eg., sudo ./install_kubeadm_worker.sh'

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
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

echo 'Verifying the kubeadm version'
kubeadm version -o short 

echo 'Disabling swap in order for the kubelet to work properly.'
swapoff -a

echo 'Before joining the master node in the cluster, check whether this token still exists and has not expired. Go to the Control - Plane node (Master node) and run the following command:
kubeadm token list'

echo 'By default, tokens expire after 24 hours. If you are joining a node to the cluster after the current token has expired, you can create a new token by running the following command on the control-plane node:'

kubeadm token create --print-join-command
echo '# The output is similar to this: # 5didvk.d09sbcov8ph2amjw'

echo 'Next, you can join the master node by running the following as root:

# sudo kubeadm join 10.0.1.11:6443 --token 264t3t.rqy1qaf0dmfpeg5f 
# --discovery-token-ca-cert-hash sha256:68c340191ad5304bca36d3dd5570feb5bc2fbb29c8c1e389f1caa621b9e9c917'
