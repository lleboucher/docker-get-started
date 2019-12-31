#!/bin/bash

master_ip_address="192.168.0.200"
token_path="/vagrant/data_k8s_token"
ca_cert_hash_path="/vagrant/data_k8s_ca_cert_hash"

# Join Kubernetes Cluster
kubeadm join --token $(cat "${token_path}") $master_ip_address:6443 --discovery-token-ca-cert-hash sha256:$(cat "${ca_cert_hash_path}")

# Enable using the cluster as 'vagrant' regular user
su vagrant -c 'mkdir -p $HOME/.kube'
su vagrant -c 'sudo cp -i /vagrant/.kube/config $HOME/.kube/'
su vagrant -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'


# Cleanup
# rm -rf "${token_path}"
# rm -rf "${ca_cert_hash_path}"
