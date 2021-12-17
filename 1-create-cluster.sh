#!/bin/bash

source ./utils.sh

# Specific k3s image versions can be found here: https://hub.docker.com/r/rancher/k3s
# They define the Kubernetes version we will be using
K3S_IMAGE="docker.io/rancher/k3s:v1.20.9-k3s1"

# Number of agents we want in the cluster
K3S_AGENTS=1

trace "Deleting simple cluster..."
k3d cluster delete simple

trace "Creating network to avoid clashing with our VPN. "
printf "\nDon't forget to configure your docker with \"bip\": \"192.168.200.0/16\"!"
printf "\nIf you are running in the office, you may also need to add our intranet DNS with your docker configuration with \"dns\": [ \"172.17.100.100\", \"8.8.8.8\"].\n"
docker network rm k3d-net > /dev/null
docker network create k3d-net --driver=bridge --gateway=192.175.243.1 --subnet=192.175.243.0/24

trace "Creating simple cluster using k3d..."
k3d cluster create simple --no-hostip --k3s-server-arg "--no-deploy=traefik" -i $K3S_IMAGE --network k3d-net --api-port 6550 -p "22:22@loadbalancer" -p "8081:80@loadbalancer" --agents $K3S_AGENTS
exit_if_error "Cloud not create cluster $CLUSTER_NAME!"

trace "Cluster created!"