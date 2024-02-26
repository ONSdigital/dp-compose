#!/usr/bin/env bash

DP_COMPOSE_V2_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source "${DP_COMPOSE_V2_DIR}/scripts/utils.sh"

# Set VERBOSE=true to debug connection issues
VERBOSE=${VERBOSE:-false}

#==| CONSTANTS |================================================
REPO_URL_REGEX='^https?:\/\/[^\/]+\/([^\/]+)\/([^\/]+)\/?$'
REPO_SSH_URL_REGEX='^(git@)?github.com:([^\/]+)\/([^\/]+)\/?(\.git)?$'

#==| FUNCTIONS |================================================

# tbc

# ==| MAIN |================================================================

# Ensure dependencies are installed
[[ -n $BASH_VERSINFO && $BASH_VERSINFO -lt 4 ]] && fatal "your 'bash' is too old, please run 'brew install bash'"
which git > /dev/null || fatal "git not installed"
which yq > /dev/null || fatal "yq not installed"

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

# Get list of repo urls from docker compose config
repos=( $(make list-repos) )

errors=()
for repo_url in ${repos[@]}; do
    # Strip '.git' extension if present
    repo_url=${repo_url%.git}
    repo_url_pp=$(colour $GREY $repo_url)

    # Parse repo URL
    if [[ "$repo_url" =~ $REPO_URL_REGEX ]]; then
        org=${BASH_REMATCH[1]}
        repo=${BASH_REMATCH[2]}
        clone_url="git@github.com:$org/$repo"
    elif [[ "$repo_url" =~ $REPO_SSH_URL_REGEX ]]; then
        repo=${BASH_REMATCH[3]}
        clone_url=$repo_url
    else
        error "failed to parse repo url: '$repo_url'"
        continue
    fi

    repo_pp="$(colour $CYAN "$(printf "%-30s" $repo)")"

    # Check if the repo already exists locally
    repo_path="${DP_REPO_DIR}/$repo"
    if [[ -d "${repo_path}" ]]; then
        branch=$(git -C "${repo_path}" rev-parse --abbrev-ref HEAD)
        br_colour=$GREEN; [[ $branch == develop ]] || br_colour=$YELLOW
        branch_pp=$(colour $br_colour $branch)
        if [[ :pull:git-status: == *:${1-}:* ]]; then
            git_arg=${1#git-}
            res=0
            git -C "${repo_path}" $git_arg || res=$?
            if [[ $res > 0 ]]; then
                error "failed to '$git_arg' repo: $repo_pp ($branch_pp $repo_url_pp)"
                errors+=( $repo )
            else
                info "successfully '$git_arg' on repo: $repo_pp ($branch_pp $repo_url_pp)"
            fi
        else
            info "repo already cloned, skipping: $repo_pp ($branch_pp $repo_url_pp)"
        fi

    elif [[ "${1-}" == "check-repos" ]]; then
        warn "no local repo: $repo_pp ($repo_url_pp) - run: $(colour $CYAN "make clone")"

    else
        # If not then clone it
        info "cloning repo...: $repo_pp ($repo_url_pp)"

        if [[ $VERBOSE = true ]]; then
            git -C "${DP_REPO_DIR}" clone "$clone_url"
        else
            git -C "${DP_REPO_DIR}" clone "$clone_url" 2> /dev/null
        fi
        if [[ $? > 0 ]]; then
            error "failed to clone repo, please make sure the repo exists and you have access to it: $repo_pp ($repo_url_pp)"
            errors+=( $repo )
        else
            info "successfully cloned repo: $repo_pp ($repo_url_pp)"
        fi
    fi
done

if [[ ${#errors[*]} > 0 ]]; then
    fatal "failed to action ${#errors[*]} repos: ${errors[*]}"
fi
info "done ${#repos[*]} repos"
