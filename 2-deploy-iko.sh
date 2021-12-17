#!/bin/bash

source ./utils.sh

get_intersystems_credentials

deploy_isc_reg_secret

msg "\nAdding Smart Data Services helm repository to helm...\n"
helm repo add sds https://intersystems.github.io/sds-charts
exit_if_error "Could no add smart data services repository to helm."

helm repo update
exit_if_error "Helm update failed."

msg "\nInstalling IKO...\n"
# helm install -f ./iko-sds-values.yaml -n "default" --version 2.1.66 intersystems-iris-operator sds/iris-operator
helm install -f ./iko-sds-values.yaml -n "default" --version 3.3.0 intersystems-iris-operator sds/iris-operator
exit_if_error "Could not install IKO into your cluster using helm."

trace "\nWaiting IKO to be ready."
while [ -z "$(kubectl get pods | grep iris-operator | grep 1/1)" ]
do
    printf "."
    sleep 1
done

trace "\nIKO is ready!\n"