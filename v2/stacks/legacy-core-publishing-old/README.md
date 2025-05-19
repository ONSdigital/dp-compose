# Legacy Publishing Stack

This stack deploys the necessary services and dependencies for the legacy functionality for publishing mode.

The basic (full) version of this stack uses:

- zebedee
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch
- topic-api
- mongodb
- zookeeper
- kafka
- kowl
- localstack
- dis-redirect-proxy
- dis-redirect-api
- redis

However, there are 2 other variants of this stack, as follows:

The redirects-only version of this stack:

- dis-redirect-proxy 
- dis-redirect-api 
- redis

The core backing services version of this stack:

- zebedee
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch
- topic-api
- mongodb
- zookeeper
- kafka
- kowl
- localstack

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. If you have never built zebedee, babbage, or the-train before, then build them before continuing (requires Java 8 to be used):

   ```shell
   cd $DP_REPO_DIR/zebedee
   make build
   cd $DP_REPO_DIR/babbage
   make build
   cd $DP_REPO_DIR/the-train
   make build
   ```

   This is required for the local docker builds to work around a current issue with the volume paths not existing pre-build. Once this issue has been resolved, this step will no longer be necessary.

3. Set the COMPOSE_FILE environment variable in local.env if required:

   For the redirects-only version of the stack, set the COMPOSE_FILE as follows in local.env:

   ```shell
   COMPOSE_FILE=redir-deps.yml:redir-services.yml
   ```

   Or, for the core backing services version of the stack, set the COMPOSE_FILE as follows in local.env:

   ```shell
   COMPOSE_FILE=core-deps.yml:core-services.yml
   ```

   Or, for the basic (full) version of this stack you will just need to make sure that any COMPOSE_FILE value, set in local.env, is commented out. 
   Then, the COMPOSE_FILE value in default.env will be used instead.

4. Begin by port-forwarding to the Identity API in sandbox. E.g. run the following commands in a terminal:

   ```shell
   aws sso login --profile=dp-sandbox
   dp ssh sandbox publishing_mount 1 -p 25600:localhost:<IDENTITY_API_URL_PORT>
   ```

   The `IDENTITY_API_URL_PORT` can be [retrieved from dp-setup](https://github.com/ONSdigital/dp-setup/blob/awsb/PORTS.md).

5. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by checking you can:

- [render a page as HTML](http://localhost:20000/economy)
- [render a page as JSON](http://localhost:20000/economy/data)
- [query zebedee for a pages data](http://localhost:23200/v1/data?uri=/economy)
- [check the health of the Redirect API](http://localhost:29900/health)
- [check the health of the Redirect Proxy](http://localhost:30000/health)

## Is it complete?

There are numerous other legacy core applications that we intend to incorporate into this stack in future including:

PDF / Table / Image rendering and management:

- dp-table-renderer
- dp-file-downloader
- dp-image-api
- dp-image-importer

Release page rendering:

- dp-release-calendar-api
- dp-frontend-release-calendar

Cache Proxy service:

- dp-legacy-cache-api
- dp-legacy-cache-proxy
