# Legacy Core Publishing Stack

This stack deploys the necessary services and dependencies to work with the legacy core stack in publishing mode.

The stack uses the sandbox instance of dp-identity-api to simplify the approach to using auth.

## Initialisation

To connect to the dp-identity-api in sandbox you will need to port forward the address.

```sh
    dp ssh sandbox publishing_mount 1 -p 25600:localhost:$IDENTITY_API_PORT
```

`$IDENTITY_API_PORT` can be found in the [list of nomad ports](https://github.com/ONSdigital/dp-setup/blob/awsb/PORTS.md)

## Testing

To know this stack is working as expected, run `make up` and then check:

- you can [login to Florence](http://localhost:8081/florence/login) with your sandbox credentials
- once logged in, you can:
  - browse the preview site (not including homepage), e.g. the [Economy page](http://localhost:8081/economy)
  - create a collection in Florence
  - make an edit to a page and view it in preview
  - submit a page for review and then review it
  - publish a manual collection
  - view the published change when not in a collection

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
