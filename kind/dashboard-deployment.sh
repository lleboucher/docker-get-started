#!/bin/bash
VERSION=v2.0.0-beta6

# BEWARE - version compatibility matters.
# Since kind is running on Kubernetes v1.15, I had to:
#   - install an older version of kubectl (1.15.17)
#       snap install kubectl --channel=1.15/stable
#   - copy the dashboard YAML file v2.0.0-beta4 which is compatible with 
#       Kubernetes v1.15:
#       * kubernetesui/dashboard:v2.0.0-beta4
#       * kubernetesui/metrics-scraper:v1.0.1
#       https://github.com/kubernetes/dashboard/releases/tag/v2.0.0-beta4



echo "Installing Kubernetes Dashboard"
kubectl apply -f dashboard-v200beta4-recommended.yaml

echo "Create sample user with the right to access the dashboard"
if [ -f dashboard-adminuser.yaml ]
then
    kubectl apply -f dashboard-adminuser.yaml
fi

if [ -z "${KUBECONFIG}" ]
then
    echo "kubeconfig is set"
fi

# Grep the secret and use it to login on the browser
# --  changed the namespace from kube-system to kubernetes-dashboard

echo "Get Token"
kubectl -n kubernetes-dashboard describe secret "$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')"

echo "Start kube proxy"
kubectl proxy -p 8080 &

echo "Launch dashboard in a web browser"

xdg-open http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

