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

# Fatal error log that exits the script with error code 2
fatal() {
    echo -e "${RED}ERROR: $@${RESET}" >&2
    exit 2
}

# Red error log
error() {
    echo -e "${RED}ERROR: $@${RESET}" >&2
}

# Yellow warning log
warning() {
    echo -e "${YELLOW}WARNING: $@${RESET}" >&2
}

# Green info log
info() {
    echo -e "${GREEN}INFO: $@${RESET}" >&2
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

