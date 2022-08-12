#!/usr/bin/env bash 

# To enable trace, uncomment line below
# set -x

##################### VARIABLES ##########################
export AWS_PROFILE=default

# prompt colours
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# services
SERVICES="babbage florence The-Train zebedee dp-api-router 
dp-cantabular-api-ext dp-cantabular-csv-exporter dp-population-types-api
dp-cantabular-filter-flex-api dp-cantabular-metadata-exporter dp-cantabular-server
dp-cantabular-xlsx-exporter dp-download-service dp-dataset-api dp-filter-api dp-frontend-router 
dp-import-api dp-import-cantabular-dataset dp-import-cantabular-dimension-options dp-recipe-api 
dp-frontend-filter-flex-dataset dp-cantabular-metadata-service dp-api-clients-go dp-topic-api"

EXTRA_SERVICES="dp-cantabular-ui dp-cantabular-server dp-kafka dp-setup dp-configs dp-ci dp-cli dp-operations
                dp-cantabular-uat sixteens dp-zebedee-utils"

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
DP_CANTABULAR_UAT_DIR="$DIR/dp-cantabular-uat"

ACTION=$1
POSTMAN_ENVIRONMENT=${2:-"local"}

##################### FUNCTIONS ##########################
logSuccess() {
    echo -e "$GREEN ${1} $RESET"
}

logError() {
    echo -e "$RED ${1} $RESET"
}

splash() {
    echo "Start Cantabular Services (SCS)"
    echo ""
    echo "Simple script to run cantabular import service locally and all the dependencies"
    echo ""
    echo "List of commands: "
    echo "   chown     - change the service '.go' folder permissions from root to the user and group."
    echo "               Useful for linux users."
    echo "   clone     - git clone all the required GitHub repos"
    echo "   down      - stop running the containers via docker-compose"
    echo "   init-db   - preparing db services. Run this once"
    echo "   help      - splash screen with all these options"
    echo "   pull      - git pull the latest from your remote repos"
    echo "   setup     - preparing services. Run this once, before 'up'"
    echo "   up        - run the containers via docker-compose"
    echo "   smoke     - run the smoke tests"
}

cloneServices() {
    cd "$DIR"
    allServices="${SERVICES} ${EXTRA_SERVICES}"
    for service in $allServices; do
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
          git pull
          logSuccess "'$repo' updated"
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
    
    chown

    upServices

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

upServices () {
    echo "Starting dp cantabular import..."
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make start-detached
    # make start
    echo "Starting dp cantabular import... Done."
    florenceLoginInfo
}


downServices () {
    echo "Stopping base services..."
    cd "$DP_COMPOSE_DIR"
    docker-compose down
    logSuccess "Stopping base services... Done."

    echo "Stopping dp cantabular import..."
    cd "$DP_CANTABULAR_IMPORT_DIR"
    make stop
    logSuccess "Stopping dp cantabular import... Done."
}

smoke () {
  POSTMAN_ENVIRONMENT=$1

  if ! command newman -v &> /dev/null
  then
    echo "ERROR: smoke tests require newman to be installed"
    echo "       https://github.com/postmanlabs/newman"
    exit

  else
    echo "Running smoke tests in enviroment '$POSTMAN_ENVIRONMENT'"
    newman run "$DP_CANTABULAR_UAT_DIR/postman/get_data_public_journey.json" -e "$DP_CANTABULAR_UAT_DIR/postman/$POSTMAN_ENVIRONMENT.postman_environment.json"
  fi
}
###########

#####################    MAIN    #########################

case $ACTION in 
"chown") chown;;
"clone") cloneServices;;
"help") splash;;
"down") downServices;;
"up") upServices;; 
"pull") pull;;
"setup") setupServices;;
"init-db") initDB;;
"smoke") smoke $POSTMAN_ENVIRONMENT;;
*) echo "invalid action - [${ACTION}]"; splash;;
esac