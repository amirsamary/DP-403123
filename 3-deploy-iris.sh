#!/bin/bash

source ./utils.sh

if [ ! -f ./iris-license/iris.key ];
then
    exit_with_error "Could not find file iris.key unde the iris-license folder."
fi

SERVICE_NAME=test-iris

if [ -n "$(helm list -n $SERVICE_NAME | awk '{print $1}' | grep $SERVICE_NAME )" ];
then
    echo
    echo -e "${YELLOW}The helm chart '$SERVICE_NAME' is already installed in namespace $SERVICE_NAME.${RESET}"
    echo "Use the following to see it for yourself:"
    echo
    echo -e "\t${WHITE}helm list -n $SERVICE_NAME${RESET}"
    echo
    echo "Use the following to delete it:"
    echo
    echo -e "\t${WHITE}helm delete $SERVICE_NAME"
    echo
    exit 1
fi

trace "\nCleaning up."
kubectl delete pvc iris-data-test-iris-data-0
kubectl delete pvc iris-journal1-test-iris-data-0
kubectl delete pvc iris-journal2-test-iris-data-0
kubectl delete pvc iris-wij-test-iris-data-0
kubectl delete secret iris-key-secret
sleep 5 

trace "\nInjecting IRIS key..."
kubectl create secret generic iris-key-secret --from-file=$PWD/iris-license/iris.key
exit_if_error "Could not create secret iris-key-secret on the default namespace."

trace "\nDeploying IRIS..."
helm install -n default $SERVICE_NAME ./helm
exit_if_error "Failed to install IRIS Persistence Service in the cluster."

trace "\nWaiting IRIS to be ready. Be patient. It is downloading the IRIS image from containers.intersystems.com."
while [ -z "$(kubectl get pods | grep test-iris-data-0 | grep 1/1)" ]
do
    printf "."
    sleep 1
done

trace "\nIRIS is ready! Let's reproduce the problem by deleting the pod..."

kubectl delete pod test-iris-data-0
exit_if_error "Could not delete the pod!"

trace "\nThe pod has been deleted. IRIS operator will start a new one momentarily. "

msg "\nMonitor the pod with "

msg "\n\t${WHITE}kubectl get pods${RESET}"

msg "\n\nYou will see the pod being restarted by IKO and then failing. Use the folowing command to see the logs:"

msg "\n\t${WHITE}kubectl logs test-iris-data-0${RESET}"

msg "\n\nYou will see the error ${RED}Error during Upgrade,ERROR #5001: Unable to find Registry entry for directory /usr/irissys
[ERROR] See /irissys/data/IRIS/mgr/messages.log for more information${RESET}.\n\n"




