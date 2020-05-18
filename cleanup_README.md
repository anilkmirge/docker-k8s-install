# This steps will help us clean the k8s cluster and node on the master

### First get the node name

`kubectl get node`

`kubectl drain <node name> --delete-local-data --force --ignore-daemonsets`

---

### Delete the node

`kubectl delete node <node name>`

### Then, on the node being removed, reset all kubeadm installed state:

`sudo kubeadm reset`

### Finally, the reset process does not reset or clean up iptables rules or IPVS tables. If you wish to reset iptables, you must do so manually:

`sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X`

### (Optional) This may not be required. But, if you want to reset the IPVS tables, you must run the following command:

`ipvsadm -C`

### Sometimes, you might have an issue running kubectl commands in the worker nodes. [ec2-user@ip-10-0-1-241 ~]$ kubectl get podserror: no configuration has been provided, try setting KUBERNETES_MASTER environment variable

### This might mean that the token that the worker previously used got expired, so we might need to reconnect to the master with a new token. So, one of the easiest option is to recreate the token in the master node by running 

```$[master] sudo kubeadm token create --print-join-command```

### Next, reset the kubeadm configuration on the worker nodes.

```[worker~]$ sudo kubeadm reset```

```[worker~]$ sudo su[root@worker]# iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -Xexit```

### If everything goes well, you should see the following output.

[worker ~]$ sudo kubeadm join 10.0.1.214:6443 --token j7grgd.w3350jklbjmjebs0     --discovery-token-ca-cert-hash sha256:c81b8b42d3a46f9b0d7852793bbf637aed44dd3c7afb58ae9331ca24b84004cc
