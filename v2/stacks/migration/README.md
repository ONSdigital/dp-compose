# Migration Stack

This stack deploys the necessary services and dependencies to work with the migration stack which has elements of the legacy-core and dataset-catalogue stacks.

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

3. For most use cases, you will want to run the stack with dp-topic-api and dp-permissions-api database seeded.

   To run the seeding you will need mongosh installed:

   ```sh
   brew install mongosh
   ```

   To run the services with seeding, run:

   ```shell
   make up-with-seed
   ```

   This will start all the containers (including mongodb) and then run the seeding scripts.

   The seeding scripts assume that the repositories on your system are in the same root as `dp-compose` or that you have an environment variable set for `$DP_REPO_DIR`.

   If that is not the correct location, you will be prompted to input a custom location for dp-topic-api or dp-permissions-api on your system.

   When the scripts run, you should see something like the below in your terminal:

   ```shell
   Found dp-topic-api at {some-path}/dp-topic-api
   mongosh localhost:27017/topics ./scripts/seed-database/index.js
   creating collections

   Seeding permissions API database...
   Found dp-permissions-api at {some-path}/dp-permissions-api
   ```

   If any service hasn't picked up it's topic or permissions cache, you can force a refresh via `SERVICE={serviceName} make restart`.

   If you don't want to run the stack with the databases seeded, you can use:

   ```sh
      make up
   ```

## How to test it's all working together

1. Access the authentication stub login page <http://localhost:29500/florence/login>
2. Login as the admin user
3. Obtain the `access_token` from your cookies (minus the 'Bearer ' prefix)
4. Make a POST request to localhost:30100/v1/migration-jobs with these following payloads, depending on what you are testing (using the `access_token` as the `Authorization` header).

   In response you should receive a 202 created request, and the `state` should be `submitted`.

   a. Testing with a simple dataset

   ```json
   {
      "source_id": "/employmentandlabourmarket/peopleinwork/workplacedisputesandworkingconditions/datasets/labourdisputeslabourdisputesannualestimates",
      "target_id": "new-dataset",
      "type": "static_dataset"
   }
   ```

   b. Testing with a dataset that has edition as 'Current'

   ```json
   {
      "source_id": "/businessindustryandtrade/business/activitysizeandlocation/datasets/businessdemographyreferencetable",
      "target_id": "new-dataset",
      "type": "static_dataset"
   }
   ```

5. Make a GET request to localhost:30100/v1/migration-jobs with the same `access_token` as the `Authorization header`.

   You should now be able to see the migration job's state as `in_review` if the migration has been successful.

6. Now, make a GET request to localhost:22000/datasets using the `access_token` as the `Authorization` header

You should now be able to see your successfully migrated dataset in the dp-dataset-api.

## Working with migration data

We have provided a `reset` target to help with repeated test runs - you can run this via:

```sh
make reset
```

This will clear the `dp-dataset-api` and `dis-migration-service` mongo collections of data to re-run a migration. It will also
remove the created collection in zebedee.
