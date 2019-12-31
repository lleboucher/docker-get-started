#!/bin/bash

# Shared cluster's token information
MASTER_IP_ADDRESS="192.170.0.200"
token_path="/vagrant/token_k8s"
ca_cert_hash_path="/vagrant/token_ca_cert_hash"

# Join the Kubernetes Cluster
kubeadm join --token $(cat "${token_path}") $MASTER_IP_ADDRESS:6443 --discovery-token-ca-cert-hash sha256:$(cat "${ca_cert_hash_path}")


# Cleanup
# rm -rf "${token_path}"
# rm -rf "${ca_cert_hash_path}"
