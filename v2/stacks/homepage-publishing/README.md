# Homepage publishing

This stack deploys the necessary services and dependencies for testing the editing and publishing of the homepage.

If you only need to test the rendering of the homepage, see the [`homepage-web`](../homepage-web/) stack.

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
