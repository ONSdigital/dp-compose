# Legacy Core Proxies Stack

This stack deploys the necessary services and dependencies for the legacy core functionality for web mode. 
It also deploys a new Redirect Proxy service, and Redirect API, which use Redis, a NoSQL key-value store, to help determine where to redirect URLs in the website.

The basic version of this stack uses:

- zebedee-reader
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch
- dis-redirect-proxy
- dis-redirect-api
- redis

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

3. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by checking you can:

- [render a page as HTML](http://localhost:20000/economy)
- [render a page as JSON](http://localhost:20000/economy/data)
- [query zebedee for a pages data](http://localhost:23200/v1/data?uri=/economy)
