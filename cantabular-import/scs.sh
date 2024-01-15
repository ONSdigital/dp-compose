#!/usr/bin/env bash 

# To enable trace, uncomment line below
# set -x

##################### VARIABLES ##########################
export AWS_PROFILE=default

# prompt colours
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# services
SERVICES="babbage dp-api-clients-go dp-api-router dp-cantabular-api-ext dp-cantabular-csv-exporter dp-cantabular-dimension-api
          dp-cantabular-filter-flex-api dp-cantabular-metadata-exporter dp-cantabular-metadata-service dp-cantabular-server
          dp-cantabular-ui dp-cantabular-xlsx-exporter dp-code-list-api dp-dataset-api dp-dataset-exporter dp-dataset-exporter-xlsx
          dp-dimension-extractor  dp-dimension-importer dp-dimension-search-api dp-dimension-search-builder dp-download-service
          dp-filter-api dp-hierarchy-api dp-hierarchy-builder dp-image-api dp-image-importer dp-import dp-import-api
          dp-import-cantabular-dataset dp-import-cantabular-dimension-options dp-import-tracker dp-publishing-dataset-controller
          dp-recipe-api dp-topic-api dp-zebedee-content dp-zebedee-utils zebedee"

FRONTEND_SERVICES="dp-frontend-filter-dataset-controller dp-frontend-filter-flex-dataset dp-frontend-geography-controller
                   dp-frontend-homepage-controller dp-frontend-router dp-frontend-cookie-controller
                   dp-frontend-dataset-controller dp-frontend-feedback-controller"

EXTRA_SERVICES="dp dp-cantabular-ui dp-cantabular-uat dp-code-list-scripts dp-component-test dp-compose dp-design-system dp-kafka dp-net
                dp-mongodb-in-memory dp-setup dp-configs dp-ci dp-cli dp-operations dp-cantabular-uat sixteens dp-zebedee-utils
                dp-vault the-train"

# current directory
DIR="$( cd "$( dirname "$0" )/../.." && pwd )"

# directories
DP_COMPOSE_DIR="$DIR/dp-compose"
DP_FLORENCE_DIR="$DIR/florence"
DP_THE_TRAIN_DIR="$DIR/the-train"
DP_CANTABULAR_IMPORT_DIR="$DP_COMPOSE_DIR/cantabular-import"
DP_CANTABULAR_SERVER_DIR="$DIR/dp-cantabular-server"
DP_CANTABULAR_API_EXT_DIR="$DIR/dp-cantabular-api-ext"
DP_FRONTEND_ROUTER_DIR="$DIR/dp-frontend-router"
DP_CANTABULAR_METADATA_SERVICE_DIR="$DIR/dp-cantabular-metadata-service"
DP_FRONTEND_FILTER_FLEX_DATASET_DIR="$DIR/dp-frontend-filter-flex-dataset"
DP_FRONTEND_DATASET_CONTROLLER_DIR="$DIR/dp-frontend-dataset-controller"
ZEBEDEE_DIR="$DIR/zebedee"
ZEBEDEE_GENERATED_CONTENT_DIR=${zebedee_root}

EXPECTED_RUNNING_SERVICES=35
NUMBER_OF_RETRIES=3

##################### FUNCTIONS ##########################
logSuccess() {
    echo -e "$GREEN${1}$RESET"
}

logWarning() {
    echo -e "$YELLOW${1}$RESET"
}

logError() {
    echo -e "$RED${1}$RESET"
}

isGumInstalled() {
   command -v gum &> /dev/null
}

splash() {
    if isGumInstalled
    then
        cd "$DP_CANTABULAR_IMPORT_DIR"
        gum style \
        	--foreground 212 --border-foreground 57 --border double \
            --align center --width 50 --margin "1 2" --padding "2 4" \
        	'Start Cantabular Services (SCS)' \
        	'' \
        	'Simple script to run cantabular import service locally and all the dependencies'

        cat scs-helper.txt | gum choose --no-limit | gumOptions $(awk '{print $1}')

    else
        echo "Start Cantabular Services (SCS)"
        echo ""
        echo "Simple script to run cantabular import service locally and all the dependencies"
        echo ""
        echo "List of commands: "
        echo "   chown           - change the service '.go' folder permissions from root to the user and group. Useful for linux users."
        echo "   clone           - git clone all the required GitHub repos"
        echo "   fe-assets       - generate Cantabular FE assets"
        echo "   init-db         - preparing db services. Run this once"
        echo "   pull [branch]   - by default it will pull the latest from the current branch. Optionally, provide a branch to pull from, e.g., 'scs pull develop'"
        echo "   setup           - preparing services. Run this once"
        echo "   start           - run the containers via docker-compose with logs attached to terminal"
        echo "   start-detached  - run the containers via docker-compose with detached logs (default option)"
        echo "   stop            - stop running the containers via docker-compose"
    fi
}

cloneServices() {
    cd "$DIR"
    allServices="${SERVICES} ${EXTRA_SERVICES}"
    for service in $allServices; do
        git clone git@github.com:ONSdigital/${service}.git 2> /dev/null
        logSuccess "Cloned $service"
    done
    for service in $FRONTEND_SERVICES; do
        git clone git@github.com:ONSdigital/${service}.git 2> /dev/null
        logSuccess "Cloned $service"
    done
    for service in $EXTRA_SERVICES; do
        git clone git@github.com:ONSdigital/${service}.git 2> /dev/null
        logSuccess "Cloned additional $service"
    done
}


pull() {
    cd "$DIR"
    for repo in $(ls -d $DIR/*/); do
        cd "${repo}"
        if [ -d ".git" ]; then
            if ! [ -z ${1} ]; then
                git fetch -a --quiet 2> /dev/null
                git checkout ${1} --quiet 2> /dev/null
                if  [ $? -ne 0 ]; then
                    git checkout develop --quiet 2> /dev/null
                    if  [ $? -ne 0 ]; then
                        git checkout main --quiet 2> /dev/null
                        if  [ $? -ne 0 ]; then
                            git checkout master --quiet 2> /dev/null
                            if  [ $? -ne 0 ]; then
                                logError "ERROR - Could not checkout $1, develop, main or master branches for $repo."
                                logWarning "Please investigate it manually."
                                exit -1
                            fi
                        fi
                    fi
                fi
            fi
            CURRENT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
            printf "${GREEN} ${repo} ${RESET}on branch [$YELLOW $CURRENT_BRANCH_NAME $RESET]... "
            git pull
        fi
    done
}


initDB() {
    echo "Importing Recipes & Dataset documents..."
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make init-db
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to import MongoDB initial datasets"
        exit 129
    fi
    logSuccess "Importing Recipes & Dataset documents... Done."
}

florenceLoginInfo () {
    logSuccess "Florence is available at http://localhost:8081/florence"
    logSuccess "         if 1st time accessing it, the credentials are: florence@magicroundabout.ons.gov.uk / Doug4l"
}

checkEnvironmentVariables() {
  if [ -z $(echo "$DP_CLI_CONFIG") ]; then
    logError "Error - Environment variable [DP_CLI_CONFIG] is not defined"
    exit 129
  fi

  if [ -z $(echo "$zebedee_root") ]; then
    logError "Error - Environment variable [zebedee_root] is not defined"
    exit 129
  fi
}

setupFEAssets () {
    logSuccess "Make Assets for dp-frontend-router..."
    cd "$DP_FRONTEND_ROUTER_DIR"
    git checkout develop && git pull
    make assets
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build dp-frontend-router assets"
        exit 129
    fi
    logSuccess "Make Assets for dp-frontend-router... Done."

    logSuccess "Generate prod for $DP_FRONTEND_DATASET_CONTROLLER_DIR..."
    cd "$DP_FRONTEND_DATASET_CONTROLLER_DIR"
    git checkout develop && git pull
    make generate-prod
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to generate-prod for 'dp-frontend-dataset-controler'"
        exit 129
    fi
    logSuccess "Generate prod for $DP_FRONTEND_DATASET_CONTROLLER_DIR... Done."

    logSuccess "Generate prod for $DP_FRONTEND_FILTER_FLEX_DATASET_DIR..."
    cd "$DP_FRONTEND_FILTER_FLEX_DATASET_DIR"
    git checkout develop && git pull
    make generate-prod
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to generate-prod for 'dp-frontend-filter-flex-dataset'"
        exit 129
    fi
    logSuccess "Generate prod for $DP_FRONTEND_FILTER_FLEX_DATASET_DIR... Done."
}

setupServices () {
    checkEnvironmentVariables

    logSuccess "Remove zebedee docker image and container..."
    zebedeeContainer=$(docker ps --filter=name='zebedee' --format="{{.Names}}")
    if [ $zebedeeContainer ]; then
      docker rm -f $zebedeeContainer
    fi

    zebedeeImage=$(docker images --format '{{.ID}}' --filter=reference="*zebedee*:*")
    if [ $zebedeeImage ]; then
      docker rmi -f $zebedeeImage
    fi
    logSuccess "Remove zebedee docker image and container... Done."

    logSuccess "Build zebedee..."
    cd "$ZEBEDEE_DIR"
    git checkout develop
    git reset --hard; git pull
    # mvn clean install
    make build build-reader
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build zebedee"
        exit 129
    fi
    logSuccess "Build zebedee...  Done."

    logSuccess "Clean zebedee_root folder..."
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make full-clean
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to clean zebedee_root folder and download the CMS content"
        exit 129
    fi
    logSuccess "Clean zebedee_root folder... Done."

    logSuccess "Setup metadata service..."
    cd "$DP_CANTABULAR_METADATA_SERVICE_DIR"
    git checkout develop && git pull
    make setup
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to setup 'dp-cantabular-metadata-service'"
        exit 129
    fi
    logSuccess "Setup metadata service... Done."

    logSuccess "Build florence..."
    cd "$DP_FLORENCE_DIR"
    git checkout develop && git reset --hard && git pull
    make node-modules && make generate-go-prod
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build 'florence'"
        exit 129
    fi
    logSuccess "Build florence...  Done."

    logSuccess "Build the-train..."
    cd "$DP_THE_TRAIN_DIR"
    git checkout develop && git pull
    make build
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build 'the-train'"
        exit 129
    fi
    logSuccess "Build the-train... Done."

    logSuccess "Preparing dp-cantabular-server..."
    cd "$DP_CANTABULAR_SERVER_DIR"
    git checkout develop && git pull
    make setup
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build 'dp-cantabular-server'"
        exit 129
    fi
    logSuccess "Preparing dp-cantabular-server... Done."

    logSuccess "Preparing dp-cantabular-api-ext..."
    cd "$DP_CANTABULAR_API_EXT_DIR"
    git checkout develop && git pull
    make setup
    if [ $? -ne 0 ]; then
        logError "ERROR - Failed to build 'dp-cantabular-api-ext'"
        exit 129
    fi
    logSuccess "Preparing dp-cantabular-api-ext... Done."

    setupFEAssets
    
    chown

    startServices

    initDB

    florenceLoginInfo
}

chown() {
    # list of services that have the '.go' folder
    listOfServices=$(ls -l ./*/.go | grep ".go" | awk -F'/' '{print $2}')

    user=$(id -u --name)
    group=$(id -g --name)
    for service in $listOfServices; do
        sudo chown $user:$group -R ${DIR}/${service}/.go
    done

    sudo chown $user:$group -R ${ZEBEDEE_GENERATED_CONTENT_DIR}
    sudo chmod 755 -R ${ZEBEDEE_GENERATED_CONTENT_DIR}
}

startDetachedServices () {
    cd "$DP_CANTABULAR_IMPORT_DIR"
    logSuccess "Starting dp cantabular import..."
    make start-detached

    numStartedSrv=$(docker ps | grep -v CONTAINER | wc -l)
    attempt=0

    while [ $numStartedSrv -ne $EXPECTED_RUNNING_SERVICES ] && [ $attempt -lt $NUMBER_OF_RETRIES ];  do
        attempt=$(( $attempt+1 ))
        logWarning "Attempting to start missing services. Expecting $EXPECTED_RUNNING_SERVICES running services."
        logWarning "Number of services running: $numStartedSrv"
        logWarning "Attempt $attempt of 3"
        sleep $(( 2*$attempt ))
        make start-detached
        numStartedSrv=$(docker ps | grep -v CONTAINER | wc -l)
    done

    if [ $numStartedSrv -lt $EXPECTED_RUNNING_SERVICES ]; then
         logWarning "Not all services started successfully. Expecting $EXPECTED_RUNNING_SERVICES running services."
         logWarning "Number of services started/running: $numStartedSrv"
    else
         logSuccess "Starting dp cantabular import... Done."
    fi
    florenceLoginInfo
}

startServices () {
    logSuccess "Starting dp cantabular import..."
    florenceLoginInfo
    logWarning "Expecting $EXPECTED_RUNNING_SERVICES running services."
    logWarning "Please ensure those are running in a separate terminal."
    sleep 3
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make start
}


downServices () {
    logSuccess "Stopping dp cantabular import..."
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make stop
    logSuccess "Stopping dp cantabular import... Done."
}
gumOptions() {
    if ! [ -z $1 ]; then
        options $1
    fi

}
options() {
    case "$1" in
    "chown") chown;;
    "clone") cloneServices;;
    "help") splash;;
    "fe-assets") setupFEAssets;;
    "init-db") initDB;;
    "pull") pull "$2";;
    "setup") setupServices;;
    "start-detached") startDetachedServices;;
    "start") startServices;;
    "stop") downServices;;
    *) splash;;
    esac
}

#####################    MAIN    #########################

options "$@"
