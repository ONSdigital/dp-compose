# Homepage publishing

This stack deploys the necessary services and dependencies for testing the editing and publishing of the homepage.

If you only need to test the rendering of the homepage, see the [`homepage-web`](../homepage-web/) stack.

This stack requires the use of the sandbox dp-identity-api. You will need to tunnel to it by running:

```sh
   dp ssh sandbox publishing_mount 1 -p 25600:localhost:<IDENTITY_API_URL_PORT>
```

The `IDENTITY_API_URL_PORT` can be [retrieved from dp-setup](https://github.com/ONSdigital/dp-setup/blob/awsb/PORTS.md).

## Getting started

To run the stack:

1. Clone the repos needed for the stack:

   ```shell
   make clone
   ```

2. If you have never built zebedee, babbage and the-train before, then build them before continuing (requires Java 8 to be used):

   ```shell
   cd $DP_REPO_DIR/zebedee
   make build
   cd $DP_REPO_DIR/babbage
   make build
   cd $DP_REPO_DIR/the-train
   make build
   ```

   This is required for the local docker builds to work around a current issue with the volume paths not existing pre-build. Once this issue has been resolved, this step will no longer be necessary.

3. Build and start the stack:

   ```shell
   make up
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).
