#!/bin/bash

source $ISC_PACKAGE_INSTALLDIR/sds/imageBuildingUtils.sh

prepare_databases_for_writing;

printf "\nLoading base installer...\n"

# Can't load our source code with NOSTU. We need our namespace to be available. So, let's start iris...
iris start iris

# Now let's load and run the base class for our Installer. This will just load the class IRISConfig.BaseInstaller.cls
load_and_run_base_installer;

# Finally, we can load IRISConfig.Installer and run it
load_and_run_installer;

# Cleanning up the base image
clean_up;

exit $?