#!/bin/bash

# Vagrant hack: from https://github.com/Yolean/kubeadm-vagrant
sed -i 's/127.*k8s/#\0/' /etc/hosts
printf "192.168.0.200  k8s-master k8s-master\n" >> /etc/hosts
printf "192.168.0.211  k8s-slave1 k8s-slave1\n" >> /etc/hosts
printf "192.168.0.212  k8s-slave2 k8s-slave2\n" >> /etc/hosts

# Disable Swap. You MUST disable swap in order for the kubelet to work properly
swapoff -a
sed -r 's/^(.*swap.*)$/# \1/g' -i /etc/fstab

# install docker and run it as a service

apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/debian stretch stable"
apt-get update
apt-get install -y docker-ce

systemctl enable docker && systemctl start docker

# install kubernetes

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update
apt-get install -y kubelet kubeadm kubectl

