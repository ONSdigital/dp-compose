#!/usr/bin/env bash 

# Set DP_REPO_DIR to override the default repo cloning location
DP_REPO_DIR=${DP_REPO_DIR:-${DP_COMPOSE_V2_DIR}/../..}

set -euo pipefail

# prompt colours
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

colour() {
    local colour=$1; shift
    local RESET_safe="${RESET//\[/\\[}"
    echo -e "${colour}${@//${RESET_safe}/${RESET}${colour}}${RESET}"
}

# Fatal error log that exits the script with error code 2
fatal() {
    colour ${RED} "ERROR: $@" >&2
    exit 2
}

# Red error log
error() {
    colour ${RED} "ERROR: $@" >&2
}

# Yellow warning log
warning() {
    colour ${YELLOW} "WARNING: $@" >&2
}

# Green info log
info() {
    colour ${GREEN} "INFO: $@" >&2
}

# For cloneServices, please set:
#  - $SERVICES - a space separated list of services
#  - $DIR - the directory to install services
cloneServices() {

    cd "$DIR"

    for service in $SERVICES; do
        git clone git@github.com:ONSdigital/${service}.git 2> /dev/null
        logSuccess "Cloned $service"
    done
}

logSuccess() {
    echo -e "$GREEN${1}$RESET"
}

logWarning() {
    echo -e "$YELLOW${1}$RESET"
}

logError() {
    echo -e "$RED${1}$RESET"
}

