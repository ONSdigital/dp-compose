#!/usr/bin/env bash

CMD=$*

PREFIX="../cantabular-import/"

# from PREFIX directory
files=(
    babbage.yml 
    dp-cantabular-api-ext.yml 
    dp-cantabular-metadata-service.yml 
    dp-cantabular-server.yml 
    dp-dataset-api.yml 
    dp-download-service.yml 
    dp-frontend-dataset-controller.yml 
    dp-frontend-router.yml 
    dp-import-api.yml 
    dp-import-cantabular-dataset.yml 
    dp-import-cantabular-dimension-options.yml 
    dp-publishing-dataset-controller.yml 
    dp-recipe-api.yml 
    zebedee.yml 
    the-train.yml 
    # local
    florence.yml
    dp-api-router.yml
    mini-deps.yml
    dp-cantabular-metadata-extractor-api.yml
)


for i in "${files[@]}"
do
    if [[ ! $i =~ /#/ ]]; then
        if [[ -e "$i" ]]; then
            COMPOSE_FILE="$COMPOSE_FILE"$i:
        else 
            COMPOSE_FILE="$COMPOSE_FILE""$PREFIX""$i":
        fi 

    fi
done

# strip final :
COMPOSE_FILE=${COMPOSE_FILE%:*} \
COMPOSE_PROJECT_NAME=cantabular-metadata-pub \
COMPOSE_PATH_SEPARATOR=: docker-compose $CMD
