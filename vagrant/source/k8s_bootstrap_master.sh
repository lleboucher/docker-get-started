#!/bin/bash


# Initialize the cluster
########################

master_ip_address="192.168.0.200"
token_path="/vagrant/data_k8s_token"
ca_cert_hash_path="/vagrant/data_k8s_ca_cert_hash"
dashboard_token_path="/vagrant/data_dashboard_token"
config_files_path="/vagrant/source"

# Generate token to be shared between master and nodes
kubeadm token generate > "${token_path}"

# Init Kubeadm 
kubeadm init --token $(cat "${token_path}") --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$master_ip_address

# Generate discovery token ca cert hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > "${ca_cert_hash_path}"

# Enable using the cluster as root
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Enable using the cluster as 'vagrant' regular user
su vagrant -c 'mkdir -p $HOME/.kube'
su vagrant -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
su vagrant -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'

# Save the precious 'config' file on the shared directory
su vagrant -c 'mkdir -p /vagrant/.kube'
su vagrant -c 'sudo cp -i $HOME/.kube/config /vagrant/.kube/'


# Flannel
# For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init
# curl -o /vagrant/kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
# ... use the private interface, https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/ - Default NIC When using flannel as the pod network in Vagrant
# sed 's#"/opt/bin/flanneld",#"/opt/bin/flanneld", "--iface=eth1",#' -i /vagrant/kube-flannel.yml
kubectl apply -f $config_files_path/vagrant/kube-flannel.yaml

# Enable pods scheduling on Master
kubectl taint nodes --all node-role.kubernetes.io/master-

# Deploy the web UI - the Dashboard
###################################

# IT SEEMS IMPORTANT TO WAIT UNTIL THE CORE SERVICES ARE UP AND RUNNING.
# SOI WE INHIBIT THIS SECTION

# Deploy the service
#kubectl apply -f $config_files_path/dashboard-v200b8-recommended.yaml

# Create the user and role associated
#kubectl apply -f $config_files_path/dashboard-adminuser.yaml
#kubectl apply -f $config_files_path/dashboard-adminrole.yaml

# Extract the token needed to connect from the browser, and copy it to file
#admin_profile=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
#dashboard_token_full=$(kubectl -n kubernetes-dashboard describe secret $admin_profile | grep "token: ")
#echo ${dashboard_token_full#"token: "} > "${dashboard_token_path}"

