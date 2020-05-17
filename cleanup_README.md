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
