#!/usr/bin/env bash 

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\033[1;33m" 
RESET="\e[0m"

CONTAINERS="cantabular-import-journey_florence_1 
cantabular-import-journey_dp-import-cantabular-dimension-options_1
cantabular-import-journey_dp-recipe-api_1
cantabular-import-journey_dp-dataset-api_1
cantabular-import-journey_dp-cantabular-filter-flex-api_1
cantabular-import-journey_dp-cantabular-csv-exporter_1
cantabular-import-journey_dp-filter-api_1
cantabular-import-journey_dp-cantabular-xlsx-exporter_1
cantabular-import-journey_dp-download-service_1
cantabular-import-journey_dp-import-cantabular-dataset_1
cantabular-import-journey_dp-cantabular-metadata-exporter_1
cantabular-import-journey_dp-api-router_1
cantabular-import-journey_dp-cantabular-dimension-api_1
cantabular-import-journey_dp-frontend-filter-flex-dataset_1
cantabular-import-journey_dp-publishing-dataset-controller_1
cantabular-import-journey_dp-population-types-api_1
cantabular-import-journey_dp-cantabular-api-ext_1
cantabular-import-journey_dp-import-api_1
"
# cantabular-import-journey_dp-frontend-dataset-controller_1
# cantabular-import-journey_dp-cantabular-server_1
# cantabular-import-journey_babbage_1
# cantabular-import-journey_dp-import-api_1
# cantabular-import-journey_mongodb_1
# cantabular-import-journey_zookeeper-1_1
# cantabular-import-journey_the-train_1
# cantabular-import-journey_vault_1
# cantabular-import-journey_kowl_1
# cantabular-import-journey_postgres_1
# cantabular-import-journey_dp-frontend-router_1
# cantabular-import-journey_dp-cantabular-metadata-service_1
# cantabular-import-journey_kafka-2_1
# cantabular-import-journey_kafka-1_1
# cantabular-import-journey_kafka-3_1
# cantabular-import-journey_zebedee_1
# cantabular-import-journey_minio_1

TIME=$1
PASSED_CONTAINERS=$2

if [ "$1" = "--help" ] | [ -z "$TIME" ]
then
  echo ""
  echo "This will pull lines matching 'error' or 'DATA RACE' from docker logs for all the containers in the script" 
  echo ""
  echo "param 1: number of min since logs to be displayed"
  echo ""
  echo "param 2: pass the containers is you dont want to use 
	default containers in the script"
  exit
fi

if [ ! -z "$PASSED_CONTAINERS" ]
then
  CONTAINERS="$PASSED_CONTAINERS"
fi


for container in $CONTAINERS; do

  echo "==========================================================================="
  echo " "
  echo -e "$YELLOW logs for container : $container $RESET"
  echo ""
  #  echo "time is:" $TIME'm'
  docker logs --since=$TIME'm' $container | grep -E -B 10 -A 30 'error|DATA RACE' 
     
done


