# Dataset Catalogue Stack

This stack deploys the necessary services and dependencies to work with the dataset catalogue stack.

- The stack uses a local [stub](https://github.com/ONSdigital/dis-authentication-stub) for user authentication

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
