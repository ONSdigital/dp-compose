# dp-compose

A project to assist in composing multiple DP services

Running dp-compose assumes Docker is running natively and not in a VM. On a Mac this requires Colima:

[Setting up Colima locally](setting-up-colima-locally.md)

## V2

There is a version 2 folder (`v2`), which contains different docker compose definitions for each stack.

Please, have a look at the [version 2 README](./v2/README.md) for more information,
especially if you are new to dp-compose.

## Non-v2 stacks

There are some stacks in this directory (not the `v2` directory) which follow the below documentation, but we recommend starting with the (above) V2 stacks before using these.

More information about the kafka cluster [here](./kafka-cluster.md).

### Run

You may run containers for all required backing services by doing one of the following:

- Run `docker-compose up`
- Using the `./run.sh` script does the same thing.
- Run `make start` to start the kafka cluster containers

You can run `make stop` to stop the containers, or `make clean` to stop and remove them as well.

**If you're running for the first time** you will need to seed the Mongo database and create the collections for the first time. Run the [init-db.sh](https://github.com/ONSdigital/dp-compose/blob/main/cantabular-import/helpers/init-db.sh) script to create recipe and dataset related collections.

## CMD

The ONS website and CMD both require Elasticsearch but (annoyingly) require different versions. The `docker-compose.yml` will start 2 instances.

**Note:** The default ports for Elasticsearch is usually `9200` & `9300` however in order to avoid a port conflict
 when running 2 different versions on the same box at the same time the CMD instance is set to use ports `10200` & `10300`.

:warning: **Gotcha Warning** :warning:
You'll need to overwrite your ES config for the `dp-dimension-search-builder` and `dp-dimension-search-api` to use ports `10200` & `10300` to ensure they are using the correct instance.

## Versioning

Dependencies should be kept at specific versions and up-to-date with production.
Previously we were just using 'latest' and out-of-date versions which both could lead to unexpected behaviour.
This repository should be the source of truth for which versions to use for dependencies.
