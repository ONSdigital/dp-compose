# Legacy Core Stack

This stack deploys the necessary services and dependencies for the legacy core functionality for web mode.

The basic version of this stack uses:

- zebedee-reader
- babbage
- dp-frontend-router
- dp-api-router
- sixteens
- elasticsearch

## Dependencies

This stack relies on having a local zebedee content store setup correctly and the correct path set to $zebedee_root

See the [zebedee getting started guide](https://github.com/ONSdigital/zebedee#getting-started) for more information.

## Is it running successfully?

This will allow you to run the stack and:

- [render a page as HTML](http://localhost:20000/economy)
- [render a page as JSON](http://localhost:20000/economy/data)
- [query zebedee for a pages data](http://localhost:23200/v1/data?uri=/economy)

## Is it complete?

There are numerous other legacy core applications that we intend to incorporate into this stack in future including:

PDF / Table / Image rendering and management:

- dp-table-renderer
- highcharts
- dp-file-downloader
- dp-image-api
- dp-image-importer

Release page rendering:

- dp-release-calendar-api
- dp-frontend-release-calendar

Cache Proxy service:

- dp-legacy-cache-api
- dp-legacy-cache-proxy
