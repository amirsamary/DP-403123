#!/bin/bash

exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		if [ ! -z "$1" ];
		then
			echo ""
			echo "ERROR: $1"
			echo ""
		fi
		exit 1
	fi
}

go_up_tree_and_exit_if_error() {
	if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
		if [ ! -z "$1" ];
		then
			cd ..
			echo ""
			echo "ERROR: $1"
			echo ""
		fi
		exit 1
	fi
}

GIT_REPO_NAME=base_iris_triage

DOCKER_REPOSITORY=containers.intersystems.com/iscinternal/sds/$GIT_REPO_NAME
DOCKER_LOCAL_REPOSITORY=local-registry:5000/$GIT_REPO_NAME

TAG=$(cat ./VERSION)
exit_if_error "VERSION file does not exist."

IMAGE_NAME=$DOCKER_REPOSITORY:$TAG
LOCAL_IMAGE_NAME=$DOCKER_LOCAL_REPOSITORY:$TAG