#!/usr/bin/env bash

RED="\e[31m"
AMBER="\e[33m"
GREEN="\e[32m"
RESET="\e[0m"

fatal() {
    printf "${RED}ERROR: %s${RESET}\n" "${1}"
    exit 1
}

# ==| MAIN |================================================================

# Ensure jq is installed
which jq > /dev/null || fatal "jq not installed"

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

    # Get state of service
    IFS=" " read -r state health exit_code <<<"$(docker-compose ps $name --format=json | jq -r '"\(.State) \(.Health) \(.ExitCode)"')"
    health_output=""

    # Format the service state
    if [[ $state == "running"  ]]; then
        state_f="${GREEN}${state}${RESET}"
    elif [[ $exit_code > 0 ]]; then
        state_f="${RED}errored ($exit_code)${RESET}"
        ((error++))
    elif [[ -z "$state" ]]; then
        state_f="${AMBER}stopped${RESET}"
        ((warn++))
    else
        state_f="${RED}${state}${RESET}"
        ((error++))
    fi

    # If service is stopped there is no health
    if [[ -n "$state" ]]; then
        # Format health of service and get health check output if not healthy and not stopped
        if [[ $health == "healthy"  ]]; then
            health_f="${GREEN}${health}${RESET}"
        else
            health_output=$(docker inspect $(docker-compose ps -q ${name}) | jq '.[] | .State.Health.Log[-1].Output | @json')

            if [[ $health == "starting" ]]; then
                health_f="${AMBER}${health}${RESET}"
                ((warn++))
            else
                health_f="${RED}${health}${RESET}"
                ((error++))
            fi
        fi
    fi

    # Print service row to table
    if [[ $error > 0 ]]; then
        printf "${RED}X${RESET} %-40b %-20b %-20b %-40b\n" "$name" "$state_f" "$health_f" "$health_output"
    elif [[ $warn  > 0 ]]; then
        printf "${AMBER}-${RESET} %-40b %-20b %-20b %-40b\n" "$name" "$state_f" "$health_f" "$health_output"
    else
        printf "${GREEN}✔${RESET} %-40b %-20b %-20b %-40b\n" "$name" "$state_f" "$health_f" "$health_output"
    fi
done
