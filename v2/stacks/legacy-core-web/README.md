# Legacy Web Stack

This stack deploys the necessary services and dependencies for the legacy core functionality for web mode.

The basic (full) version of this stack uses:

- zebedee-reader
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch
- highcharts
- dis-redirect-proxy
- dis-redirect-api
- redis

However, there are 2 other variants of this stack, as follows:

The redirects-only version of this stack:

- dis-redirect-proxy 
- dis-redirect-api 
- redis

The core backing services version of this stack:

- zebedee-reader
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. If you have never built zebedee and babbage before, then build them before continuing (requires Java 8 to be used):

   ```shell
   cd $DP_REPO_DIR/zebedee
   make build
   cd $DP_REPO_DIR/babbage
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
     COMPOSE_FILE=deps.yml:core-ons.yml
      ```
   
   Or, for the basic (full) version of this stack you will just need to make sure that any COMPOSE_FILE value, set in local.env, is commented out. 
   Then, the COMPOSE_FILE value in default.env will be used instead.

4. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by checking you can:

- [render a page as HTML](http://localhost:20000/economy)
- [render a page as JSON](http://localhost:20000/economy/data)
- [query zebedee for a pages data](http://localhost:23200/v1/data?uri=/economy)
- [download charts as images](http://localhost:8080/chartimage?uri=/economy/environmentalaccounts/bulletins/ukenvironmentalaccounts/2015-07-09/38d8c337)
- [embed chart images into pdf downloads](http://localhost:8080/economy/environmentalaccounts/bulletins/ukenvironmentalaccounts/2015-07-09/pdf-new) <sup>*might timeout in 10s if accessed through the dp-frontend-router i.e. port 20000</sup>
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
