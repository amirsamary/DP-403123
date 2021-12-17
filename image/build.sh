#!/bin/bash

source ./buildtools.sh

# TAG=2021.1.0PYTHON.222.0 # Image suggested by Bob K. Gives error when trying to start IRIS - But it doesn't upgrade well on K8s.
# TAG=2021.1.0PYTHON.238.0 does not work. Gives us error "#8 8.817 ERROR #5002: ObjectScript error: <OBJECT DISPATCH>zInstall+23^%SYS.Python.1 *Failed to load python!!20210605-03:05:22:153710600 Error:" when trying to build the control plane
TAG=2021.2.0.619.0

LATEST_PYTHON_BUILD=$(docker-ls tags --registry https://arti.iscinternal.com  intersystems/iris | grep PYTHON | tail -1 | awk ' {print $2}')

printf "\n\nLatest Python build is $LATEST_PYTHON_BUILD. Using $TAG...\n\n"

docker build --force-rm --build-arg TAG=$TAG -t $IMAGE_NAME .
exit_if_error "Could not build the image $IMAGE_NAME"
