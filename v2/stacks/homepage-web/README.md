# Homepage web

This stack deploys the necessary services and dependencies for rendering the homepage and census hub.

This stack does not provide the apps necessary for testing the publishing of updates to the homepage. For this, please see the [`homepage-publishing`](../homepage-publishing/) stack.

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. If you have never built zebedee before, then build it before continuing (requires Java 8 to be used):

   ```shell
   cd $DP_REPO_DIR/zebedee
   make build
   ```

   This is required for the local docker build to work around a current issue with the volume paths not existing pre-build. Once this issue has been resolved, this step will no longer be necessary.

3. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Is it running successfully?

You can test your stack is running correctly by checking:

- [the homepage renders correctly](http://localhost:20000/) (you should not see any error messages displayed in the 'Main Figures' section, and should have content under both the 'In Focus` and 'Around the ONS' sections)
- [zebedee-reader returns the homepage data](http://localhost:23200/v1/data?uri=/)
- [the census hub renders correctly](http://localhost:20000/census)

## Is it complete?

No, this stack doesn't currently include the image API integration for the homepage images. The images currently displayed are the default stock images.

The missing applications are:

- dp-image-api
- dp-download-service
- an S3 stub (e.g. localstack)
