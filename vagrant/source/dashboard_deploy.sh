#!/bin/bash

dashboard_token_path="/vagrant/data_dashboard_token"
config_files_path="/vagrant/source"


# Deploy the web UI - the Dashboard
###################################

# Deploy the service
kubectl apply -f $config_files_path/dashboard-v200b8-recommended.yaml

# Create the user and role associated
kubectl apply -f $config_files_path/dashboard-adminuser.yaml
kubectl apply -f $config_files_path/dashboard-adminrole.yaml

# Extract the token needed to connect from the browser, and copy it to file
admin_profile=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
dashboard_token_full=$(kubectl -n kubernetes-dashboard describe secret $admin_profile | grep "token: ")
echo ${dashboard_token_full#"token: "} > "${dashboard_token_path}"

