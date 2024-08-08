# Configuring Huge Pages on a Linux System and Using Them in Kubernetes

This guide explains how to configure huge pages on a Linux system, create a Kind cluster with huge page support, and use them in a Kubernetes environment.

## Prerequisites

- A Linux system with root access
- Docker installed on your system
- Kubernetes and Kind installed

## 1. Configure Huge Pages on the Host System

### 1.1 Increase Huge Pages via Sysctl

To configure the number of huge pages, use the `sysctl` command. For example, to set 1024 huge pages of 2 MiB size:

```sh
sudo sysctl -w vm.nr_hugepages=1024
sudo mkdir -p /dev/hugepages
sudo mount -t hugetlbfs nodev /dev/hugepages
```
### 1.2 To verify how total and free hugepages available

`cat /proc/meminfo | grep -i huge`

To enabled hugepage on docker kindly update deamon json with below
# /etc/docker/daemon.json
```
"features": {
    "hugepages": true
}
```

## 2. Install Kind Cluster
```sh
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

I have added hugepage mount on kind config, which will enable huge page on pods if we configured it.
```
    extraMounts:
      - hostPath: /dev/hugepages
        containerPath: /dev/hugepages
```

we can verify if we got hugepages in pod by below command:
`kubectl exec -it <node-pod> -- cat /proc/meminfo | grep Huge`



