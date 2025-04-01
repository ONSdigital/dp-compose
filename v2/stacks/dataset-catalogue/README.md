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

To run the stack with dp-topic-api database seeded:

Follow the prerequsites for installing `mongosh` here - `https://github.com/ONSdigital/dp-topic-api/tree/develop/scripts`

Run:

   ```shell
   make up-with-seed
   ```

This assumes that the location of dp-topic-api on your system is `/Users/{your username}/src/github.com/ONSdigital/dp-topic-api`

If that is not the correct location, you will be prompted to input a custom location for dp-topic-api on your system.

Once the correct location is found, you should see something like:

   ```shell
Found dp-topic-api at /Users/{your username}/src/github.com/ONSdigital/dp-topic-api
mongosh localhost:27017/topics ./scripts/seed-database/index.js
creating collections
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).
