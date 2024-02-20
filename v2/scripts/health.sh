#!/usr/bin/env bash

DP_COMPOSE_V2_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source "${DP_COMPOSE_V2_DIR}/scripts/utils.sh"

# ==| MAIN |================================================================

# Ensure dependencies are installed
[[ -n $BASH_VERSINFO && $BASH_VERSINFO -lt 4 ]] && fatal "your 'bash' is too old, please run 'brew install bash'"
which jq > /dev/null || fatal "jq not installed, please run 'brew install jq'"

# List services (includes stopped and uninitialised services)
services=( $(docker-compose config --services) )
if [[ $? > 0 ]]; then
    fatal "failed to list services, make sure your compose configuration is valid"
fi

# Print table header
printf "  %-40b %-11b %-11b %-40b\n" "NAME" "STATE" "HEALTH" "HEALTH OUTPUT"

# Iterate over services
for name in ${services[@]}; do
    error=0
    warn=0
    state=""
    health=""
    exit_code=""
    state_f=""
    health_f=""

    if [[ -n ${SERVICE:-} && ! "$name" =~ "$SERVICE"* ]]; then
        printf -- "- %-40b %-11b %-11b %-40b\n" "$name" "-" "-" "skipped"
        continue
    fi

    # Get state of service
    IFS=" " read -r state health exit_code <<<"$(docker-compose ps $name --format=json | jq -r '"\(.State) \(.Health) \(.ExitCode)"')"
    health_output=""

    # Format the service state
    if [[ $state == "running" ]]; then
        state_f="${GREEN}${state}${RESET}"
    elif [[ $exit_code > 0 ]]; then
        state_f="${RED}errored ($exit_code)${RESET}"
        let error+=1
    elif [[ -z "$state" ]]; then
        state_f="${YELLOW}stopped${RESET}"
        let warn+=1
    else
        state_f="${RED}${state}${RESET}"
        let error+=1
    fi

    # If service is stopped there is no health
    if [[ -n "$state" ]]; then
        # Format health of service and get health check output if not healthy and not stopped
        if [[ $health == "healthy" ]]; then
            health_f="${GREEN}${health}${RESET}"
        else
            health_output=$(docker inspect $(docker-compose ps -q ${name}) | jq '.[] | .State.Health.Log[-1].Output | @json')

            if [[ $health == "starting" ]]; then
                health_f="${YELLOW}${health}${RESET}"
                let warn+=1
            else
                health_f="${RED}${health}${RESET}"
                let error+=1
            fi
        fi
    fi

    # Print service row to table
    col1="${GREEN}✔${RESET}"
    if [[ $error > 0 ]]; then
        col1="${RED}X${RESET}"
    elif [[ $warn > 0 ]]; then
        col1="${YELLOW}-${RESET}"
    fi
    printf "${col1} %-40b %-20b %-20b %-40b\n" "$name" "$state_f" "$health_f" "$health_output"

done
