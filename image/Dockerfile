ARG TAG

FROM arti.iscinternal.com/intersystems/iris:${TAG}

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

USER root
RUN pip3 install pyyaml 

# Going back to irisowner now
USER irisowner

ENV IRIS_PROJECT_FOLDER_NAME=src

# Used to specify a folder on the container with the source code (csp pages, classes, etc.)
# to load into the CSP application.
ENV IRIS_APP_SOURCEDIR=/tmp/iris_project/

# Name of the application. This will be used to define the namespace, database and 
# name of the CSP application of this application.
ENV IRIS_APP_NAME="USER"

# Adding source code that will be loaded by the installer
# The ADD command ignores the current USER and always add as root. 
# That is why were are doing the chown
ADD --chown=irisowner:irisuser ./${IRIS_PROJECT_FOLDER_NAME}/ $IRIS_APP_SOURCEDIR

# Adding scripts to load base image source and child image source
ADD ./imageBuildingUtils.sh $ISC_PACKAGE_INSTALLDIR/sds/imageBuildingUtils.sh
ADD ./iris-base-installer.sh $ISC_PACKAGE_INSTALLDIR/sds/iris-base-installer.sh
ADD ./iris-installer.sh $ISC_PACKAGE_INSTALLDIR/sds/iris-installer.sh

# Running iris-base-installer will trigger iris-installer too. In this case, we do have
# some basic source code from the base image that we want to load, so that is fine. Child images
# will be able to just run iris-installer.sh to load and compile their own source code.
RUN $ISC_PACKAGE_INSTALLDIR/sds/iris-base-installer.sh

HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1