#!false dot me

# Set DP_REPO_DIR to override the default repo cloning location
DP_REPO_DIR=${DP_REPO_DIR:-${DP_COMPOSE_V2_DIR}/../..}

set -euo pipefail

# colours
BOLD=$'\e[1m';      GREY=$'\e[30;1m';    RESET=$'\e[0m'
RED=$'\e[31m';      GREEN=$'\e[32m';     YELLOW=$'\e[33m';   BLUE=$'\e[34m'
MAGENTA=$'\e[35m';  CYAN=$'\e[36m';      WHITE=$'\e[37m'

# Github URL constants
HTTP_REPO_URL_PREFIX=https://github.com/ONSdigital/
SSH_REPO_URL_PREFIX=git@github.com:ONSdigital/

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

# Test ssh to github
test_github_ssh() {
    local res=0
    if [[ $VERBOSE = true ]]; then
        ssh -v -T git@github.com || res=$?
    else
        ssh -T git@github.com &>/dev/null || res=$?
    fi
    case $res in
        1)
            info "github ssh authentication successful"
            ;;
        255)
            fatal "github ssh authentication failed, ensure ssh is configured for github in order to use this script"
            ;;
        *)
            fatal "github ssh authentication encountered unexpected error"
    esac
}

# Clone an ONSdigital github repo to the standard repo directory
clone_repo() {
    local repo="$1"; shift
    local expected_branch="$1"; shift

    local repo_pp="$(colour $CYAN $repo)"

    # Check if the repo already exists locally
    local repo_path="$DP_REPO_DIR/$repo"
    if [[ -d "${repo_path}" ]]; then
        local branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
        local br_colour=$GREEN; [[ $branch == "$expected_branch" ]] || br_colour=$YELLOW
        local branch_pp=$(colour $br_colour $branch)
        info "repo already cloned, skipping: $repo_pp ($branch_pp)"
    else
        # If not then clone it
        info "cloning repo...: $repo_pp ($HTTP_REPO_URL_PREFIX$repo)"

        if [[ $VERBOSE = true ]]; then
            git -C "${DP_REPO_DIR}" clone "$SSH_REPO_URL_PREFIX$repo"
        else
            git -C "${DP_REPO_DIR}" clone "$SSH_REPO_URL_PREFIX$repo" 2> /dev/null
        fi
        if [[ $? > 0 ]]; then
            fatal "failed to clone repo, please make sure you have access to it: $repo_pp ($HTTP_REPO_URL_PREFIX$repo)"
        else
            info "successfully cloned repo: $repo_pp ($HTTP_REPO_URL_PREFIX$repo)"
        fi
    fi
}
