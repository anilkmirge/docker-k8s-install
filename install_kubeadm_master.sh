#!/bin/bash

echo 'ALERT:: Make sure you call this script as sudo. For eg., sudo ./install_kubeadm_master.sh'

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
kubeadm init --kubernetes-version $(kubeadm version -o short) --pod-network-cidr=192.168.0.0/16 | tee /tmp/kubeinit.log


echo 'To make kubectl work for your non-root user, running these commands, which are also part of the kubeadm init output:

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config'

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo 'Deploying an Overlay POD Network'
echo 'Calico will automatically detect which IP address range to use for pod IPs based on the value provided via the --pod-network-cidr flag or via kubeadm’s configuration.'

kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

echo 'Once a Pod network has been installed, you can confirm that it is working by checking that the CoreDNS Pod is Running in the output of kubectl get pods --all-namespaces.'

kubectl get pods --all-namespaces
