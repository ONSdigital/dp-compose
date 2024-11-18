#!/usr/bin/env bash

DP_COMPOSE_V2_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source "${DP_COMPOSE_V2_DIR}/scripts/utils.sh"

# Set VERBOSE=true to debug connection issues
VERBOSE=${VERBOSE:-false}

#==| CONSTANTS |================================================

ZEBEDEE_CONTENT_REPO=dp-zebedee-content

#==| FUNCTIONS |================================================

init_zebedee_content() {
    local repo_path="$1"
    if [[ ! -d "${repo_path}" ]]; then
        fatal "unexpected error: repo directory does not exist: $repo_path"
    fi

    # This is a very minimal check and does not include a check to insure that the latest content has been
    # initialised after a git pull. This has been done to prevent overwriting local test data unexpected, but
    # may be worth revisiting in the future.
    if [[ -d "${repo_path}/web" && -d "${repo_path}/publishing" ]]; then
        info "zebedee content already initialised, skipping"
    else
        info "initialising zebedee content..."
        cd $repo_path && make init
        if [[ $? > 0 ]]; then
            fatal "failed to initisalise zebedee content"
        fi
        info "successfully initialised zebedee content"
    fi
}

# ==| MAIN |================================================================

# Ensure dependencies are installed
[[ -n $BASH_VERSINFO && $BASH_VERSINFO -lt 4 ]] && fatal "your 'bash' is too old, please run 'brew install bash'"
which git > /dev/null || fatal "git not installed"

test_github_ssh
clone_repo "$ZEBEDEE_CONTENT_REPO" main
init_zebedee_content "$DP_REPO_DIR/$ZEBEDEE_CONTENT_REPO"
