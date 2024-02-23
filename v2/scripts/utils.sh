#!false dot me

# Set DP_REPO_DIR to override the default repo cloning location
DP_REPO_DIR=${DP_REPO_DIR:-${DP_COMPOSE_V2_DIR}/../..}

set -euo pipefail

# colours
BOLD=$'\e[1m';      GREY=$'\e[30;1m';    RESET=$'\e[0m'
RED=$'\e[31m';      GREEN=$'\e[32m';     YELLOW=$'\e[33m';   BLUE=$'\e[34m'
MAGENTA=$'\e[35m';  CYAN=$'\e[36m';      WHITE=$'\e[37m'

colour() {
    local colour="$1"; shift
    set -- "${@//${RESET}/${RESET}${colour}}"
    echo "${colour}$@${RESET}"
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
    colour $GREEN "$@"
}

logWarning() {
    colour $YELLOW "$@"
}

logError() {
    colour $RED "$@"
}

is_ver() {
    local app=$1;       shift
    local app_ver=$1;   shift
    local want_ver=$1;  shift
    if [[ -z $app_ver ]]; then
        warning "$(colour $CYAN $app) cannot obtain version - check for app version $(colour $GREEN "$want_ver") being installed or maybe I cannot parse the version output"
        return 1
    fi
    if [[ $app_ver =~ ^$want_ver ]]; then
        info "$(colour $CYAN $app) is version $(colour $BOLD $app_ver), wanted $(colour $BOLD "$want_ver")"
        return 0
    fi
    warning "$(colour $CYAN $app) is version $(colour $RED $app_ver), wanted $(colour $GREEN "$want_ver")"
}
