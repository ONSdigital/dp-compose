#!/usr/bin/env bash

CMD=$*

PREFIX="../cantabular-import/"

# check this
files=(
    # from PREFIX directory
    babbage.yml 
    dp-cantabular-api-ext.yml 
    dp-cantabular-metadata-service.yml 
    dp-cantabular-server.yml 
    dp-dataset-api.yml 
    dp-frontend-dataset-controller.yml 
    dp-frontend-router.yml 
    dp-import-api.yml 
    dp-import-cantabular-dataset.yml 
    dp-import-cantabular-dimension-options.yml 
    dp-publishing-dataset-controller.yml 
    dp-recipe-api.yml 
    zebedee.yml 
    the-train.yml 
    dp-filter-api.yml
    dp-cantabular-csv-exporter.yml
    dp-cantabular-xlsx-exporter.yml
    deps.yml
    dp-download-service.yml
    # new
    dp-cantabular-metadata-exporter.yml
    # local overrides present in this directory
    florence.yml
    dp-api-router.yml
    #mini-deps.yml
    dp-cantabular-metadata-extractor-api.yml
    dp-dataset-api.yml 
    # new
    dp-topic-api.yml 
    dp-cantabular-csv-exporter.yml
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
COMPOSE_PROJECT_NAME=cantabular-metadata-pub-2021 \
COMPOSE_PATH_SEPARATOR=: docker-compose $CMD
