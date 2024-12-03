# v1 Compatability Stack

:warning: This stack is only provided for backwards compatability with the original docker compose stack. It is strongly recommended that you use the product specific stacks. This stack should be treated as deprecated and not be extended.

This stack only provides the third party backing services and the MathJax API. It provides backwards compatability as a replacement for the original `docker-compose.yml` from the root of this repo.

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by running the health checks:

```shell
make health
```

## Is it complete?

Yes, this stack provides all services provided by the original docker compose stack so can be used as a replacement.

## Migrating from v1

When migrating from the v1 stack (i.e. the original docker compose stack that used to exist in the root of this repo), the commands you use to interact with this stack will be slightly different. The most notable difference is that v2 defaults to always running in detatched mode rather than following the logs for performance reasons. If you wish to follow the logs after starting an app, the additional target `LOGS_TAIL=1 make logs` needs to be added.

The following table outlines the most appropriate replacement commands to use.

v1 Command             | v2 Command
-----------------------|---------------------------
`./run.sh`             | `LOGS_TAIL=1 make up logs`
`make start`           | `LOGS_TAIL=1 make up logs`
`make start-detatched` | `make up`
`make stop`            | `make stop`
`make down`            | `make down`
`make clean`           | `make clean`
`make restart`         | `make restart`

In v2, the above commands can be limited to a single service by setting the `SERVICE` variable. For example:

```shell
SERVICE=zebedee make up
SERVICE=zebedee make logs
```

For more information about the less standard v2 make targets, see [v2 Make targets](../README.md#make-targets).

## Working with multiple Elasticsearches

This stack contains three different elasticsearch instances. In order to allow locally running apps to connect, you will need to override the default ports configured in those apps.

### Legacy Core

The legacy core will use the `elasticsearch` instance so `zebedee` and `babbage` can continue to use the default ports without change.

### CMD

You'll need to overwrite your ES config for the `dp-dimension-search-builder` and `dp-dimension-search-api` to use ports for the `cmdelasticsearch` instance (i.e. `10200` & `10300`) to ensure they are using the correct instance.

### Search Service

You'll need to overwrite your ES config for the `dp-search-api` and `dp-search-data-importer` to use ports for the `sitewideelasticsearch` instance (i.e. `11200` & `11300`) to ensure they are using the correct instance.
