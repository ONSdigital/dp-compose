#!/usr/bin/env bash

# Set DP_REPO_DIR to override the default repo cloning location
DP_COMPOSE_V2_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DP_REPO_DIR=${DP_REPO_DIR:-${DP_COMPOSE_V2_DIR}/../..}

# Set VERBOSE=true to debug connection issues
VERBOSE=${VERBOSE:-false}

#==| CONSTANTS |================================================
RED="\e[31m"
AMBER="\e[33m"
GREEN="\e[32m"
RESET="\e[0m"
REPO_URL_REGEX='^https?:\/\/[^\/]+\/([^\/]+)\/([^\/]+)\/?$'

#==| FUNCTIONS |================================================

# Fatal error log that exits the script with error code 1
fatal() {
    echo -e "${RED}ERROR: ${1}${RESET}"
    exit 1
}

# Red error log
error() {
    echo -e "${RED}ERROR: ${1}${RESET}"
}

# Green info log
info() {
    echo -e "${GREEN}INFO: ${1}${RESET}"
}

# ==| MAIN |================================================================

# Ensure dependencies are installed
[[ -n $BASH_VERSINFO && $BASH_VERSINFO -lt 4 ]] && fatal "your 'bash' is too old, please run 'brew install bash'"
which git > /dev/null || fatal "git not installed"
which yq > /dev/null || fatal "yq not installed"

# Test ssh to github
if [[ $VERBOSE = true ]]; then
    ssh -v -T git@github.com
else
    ssh -T git@github.com &>/dev/null
fi
case $? in
    1)
        info "github ssh authentication successful"
        ;;
    255)
        fatal "github ssh authentication failed, ensure ssh is configured for github in order to use this script"
        ;;
    *)
        fatal "github ssh authentication encountered unexpected error"
esac

# Get list of repo urls from docker compose config
set +o pipefail
repos=$(docker-compose config | yq -er '.services | to_entries | .[].value."x-repo-url"' | grep -v 'null' | uniq)
if [[ ${PIPESTATUS[0]} > 0 ]]; then
    fatal "failed to list repos, make sure your compose configuration is valid"
elif [[ ${PIPESTATUS[1]} > 0 ]]; then
    fatal "unexpected error while parsing docker compose config"
fi

errors=0
for repo_url in ${repos[@]}; do
    # Strip '.git' extension if present
    repo_url=${repo_url%%}

    # Parse repo URL
    if [[ "$repo_url" =~ $REPO_URL_REGEX ]]; then
        org=${BASH_REMATCH[1]}
        repo=${BASH_REMATCH[2]}
    else
        error "failed to parse repo url: '$repo_url'"
    fi

    # Check if the repo already exits
    pushd "${DP_REPO_DIR}" > /dev/null
        if [[ -d "$repo" ]]; then
            info "repo already cloned, skipping: $repo ($repo_url)"
        else
            info "cloning repo...: $repo ($repo_url)"

            # If not then clone it
            if [[ $VERBOSE = true ]]; then
                git clone "git@github.com:$org/$repo"
            else
                git clone "git@github.com:$org/$repo" 2> /dev/null
            fi
            if [[ $? > 0 ]]; then
                error "failed to clone repo, please make sure the repo exists and you have access to it: $repo ($repo_url)"
                ((errors++))
            else
                info "successfully cloned repo: $repo ($repo_url)"
            fi
        fi
    popd > /dev/null
done

if [[ $errors > 0 ]]; then
    error "failed to clone $errors repos"
else
    info "all repos have been cloned"
fi
