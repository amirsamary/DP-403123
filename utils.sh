#using part of the util script in ICMDurable

RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

function exit_if_empty {
    if [ -z "$1" ];
    then
        printf "\n\n${PURPLE}Exiting.${RESET}"
        exit 0
    fi
}

function exit_if_error {

	if [ $? -ne 0 ];
	then
		if [ "$1" != "" ];
		then
			printf "\n\n${RED}"
			echo "ERROR: $1"
			printf "\n\n${RESET}"
		fi
		exit 1
	fi
}

function exit_with_error {
	printf "\n\n${RED}Exiting: $1.${RESET}\n\n"
	exit 0
}

function msg {
	printf "\n${BLUE}$1${RESET}"
}

function option {
	printf "\n${WHITE}$1 - ${BLUE}$2${RESET}"
}

function trace {
	printf "\n\n${CYAN}$1${RESET}\n"
}

function warn {
	printf "\n\n${WHITE}$1${RESET}\n\n"
}

function get_intersystems_credentials {

	msg "\nThe setup script needs your username and token for https://containers.intersystems.com:"

    msg "\n\tUsername:"
    read ISC_REG_USR
    exit_if_empty $ISC_REG_USR

    msg "\tToken:"
    read -s ISC_REG_TOKEN
    exit_if_empty $ISC_REG_TOKEN

	export ISC_REG_USR
	export ISC_REG_TOKEN
}

function deploy_isc_reg_secret {

	trace "Deploying secret 'intersystems-container-registry-secret' in the cluster..."

	printf "\nkubectl create secret docker-registry intersystems-container-registry-secret --docker-server=https://containers.intersystems.com --docker-username=$ISC_REG_USR --docker-password=\"$ISC_REG_TOKEN\" \n"
	kubectl create secret docker-registry intersystems-container-registry-secret --docker-server=https://containers.intersystems.com --docker-username=$ISC_REG_USR --docker-password="$ISC_REG_TOKEN"
	exit_if_error "Could not deploy secret 'intersystems-container-registry-secret' in the cluster!"
	
	trace "Secret deployed."
}
