#!/usr/bin/env bash

DP_COMPOSE_V2_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source "${DP_COMPOSE_V2_DIR}/scripts/utils.sh"

REPO_DIR="$( cd "${DP_COMPOSE_V2_DIR}/../.." && pwd )"

# Set VERBOSE=true to debug connection issues
VERBOSE=${VERBOSE:-false}

#==| CONSTANTS |================================================

REPO=dp-zebedee-content
REPO_URL=https://github.com/ONSdigital/$REPO
REPO_CLONE_URL=git@github.com:ONSdigital/$REPO

#==| FUNCTIONS |================================================

clone_repo() {
    # Test ssh to github
    res=0
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

    local repo_pp="$(colour $CYAN $REPO)"

    # Check if the repo already exists locally
    local repo_path="$REPO_DIR/$REPO"
    if [[ -d "${repo_path}" ]]; then
        local branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
        local br_colour=$GREEN; [[ $branch == main ]] || br_colour=$YELLOW
        local branch_pp=$(colour $br_colour $branch)
        info "repo already cloned, skipping: $repo_pp ($branch_pp)"
    else
        # If not then clone it
        info "cloning repo...: $repo_pp ($REPO_URL)"

        if [[ $VERBOSE = true ]]; then
            git -C "${REPO_DIR}" clone "$REPO_CLONE_URL"
        else
            git -C "${REPO_DIR}" clone "$REPO_CLONE_URL" 2> /dev/null
        fi
        if [[ $? > 0 ]]; then
            fatal "failed to clone repo, please make sure you have access to it: $repo_pp ($REPO_URL)"
        else
            info "successfully cloned repo: $repo_pp ($REPO_URL)"
        fi
    fi
}

init_content() {
    local repo_path="$REPO_DIR/$REPO"
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

clone_repo
init_content
