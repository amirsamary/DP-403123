#!/bin/bash
#
# This script is just to test the container. 
#

source ./buildtools.sh

docker run --rm -it \
    -p 1972:1972 -p 52773:52773 \
    $IMAGE_NAME