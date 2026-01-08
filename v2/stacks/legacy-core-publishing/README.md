# Legacy Core Publishing Stack

This stack deploys the necessary services and dependencies to work with the legacy core stack in publishing mode.

The stack uses the sandbox instance of dp-identity-api to simplify the approach to using auth.

## Initialisation

To connect to the dp-identity-api in sandbox you will need to port forward the address.

```sh
    dp ssh sandbox publishing_mount 1 -p 25600:localhost:$IDENTITY_API_PORT
```

`$IDENTITY_API_PORT` can be found in the [list of nomad ports](https://github.com/ONSdigital/dp-setup/blob/awsb/PORTS.md)

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. Set the COMPOSE_FILE environment variable in local.env if required:

    For the basic (full) version of this stack you will just need to make sure that any COMPOSE_FILE value, set in local.env, is commented out.
    Then, the COMPOSE_FILE value in default.env will be used.

    Alternatively, the local.env file can be used to set the COMPOSE_FILE value to specify different variations of the stack, as shown below.

    For the migration services version of the stack, set the COMPOSE_FILE as follows in local.env:
  
     ```shell
     COMPOSE_FILE=migration.yml:migration-core.yml:migration-deps.yml:core.yml:static-files.yml
     ```

    For the redirects-only version of the stack, set the COMPOSE_FILE as follows in local.env:
  
     ```shell
     COMPOSE_FILE=redirect-deps.yml:redirect.yml
     ```
  
    Or, for the core backing services version of the stack, set the COMPOSE_FILE as follows in local.env:
  
     ```shell
    COMPOSE_FILE=core-deps.yml:core.yml
     ```
  
3. Ensure that the AWS access keys (environment variables) in local.env are up to date (and delete the word 'export' before each new one copied across).

4. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Testing

To know this stack is working as expected, run `make up` and then check:

- you can [login to Florence](http://localhost:8081/florence/login) with your sandbox credentials
- once logged in, you can:
  - browse the preview site (not including homepage), e.g. the [Economy page](http://localhost:8081/economy)
  - create a collection in Florence
  - make an edit to a page and view it in preview
  - submit a page for review and then review it
  - publish a manual collection
  - view the published change when not in a collection (still signed into Florence though) e.g. changes to the [Economy page](http://localhost:20000/economy)

Further functionality to test will be added as this stack is expanded and proved.

## Is it complete?

There are numerous other legacy core applications that we intend to incorporate into this stack in future including:

PDF / Table / Image rendering and management:

- dp-table-renderer
- dp-file-downloader

Release page rendering:

- dp-release-calendar-api
- dp-frontend-release-calendar

Cache Proxy service:

- dp-legacy-cache-api

Timeseries processing and publishing:

- project-brian
