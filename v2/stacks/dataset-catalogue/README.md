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

To run the stack with dp-topic-api and dp-permissions-api database seeded:

Follow the prerequsites for installing `mongosh` here - `https://github.com/ONSdigital/dp-topic-api/tree/develop/scripts`

Run:

   ```shell
   make up-with-seed
   ```

This assumes that the location of dp-topic-api on your system is `/Users/{your username}/src/github.com/ONSdigital/dp-topic-api` and that dp-permissions-api is `/Users/{your username}/src/github.com/ONSdigital/dp-permissions-api`

If that is not the correct location, you will be prompted to input a custom location for dp-topic-api or dp-permissions-api on your system.

Once the correct location is found, you should see something like:

   ```shell
Found dp-topic-api at /Users/{your username}/src/github.com/ONSdigital/dp-topic-api
mongosh localhost:27017/topics ./scripts/seed-database/index.js
creating collections

Seeding permissions API database...
Found dp-permissions-api at /Users/{your username}/src/github.com/ONSdigital/dp-permissions-api
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Using `localstack` for running Dataset Ingest pipelines locally

The `localstack` service can be used to run the Dataset Ingest pipelines locally. To interact with the Dataset Ingest pipelines, run `make up-with-seed` as normal, then run the following commands in the `dis-infra-data-pipeline-stack` repo:

1. From the root directory, make sure that the Python virtual environment is activated, and install the necessary Python packages:

   ```bash
   source .venv/bin/activate
   make install
   ```

   This will install the `terraform-local` package, which is required to apply the pipeline infrastructure.

2. Navigate to `environments/60_local` and run:

   ```bash
   tflocal init
   tflocal apply
   ```

   Enter `yes` to apply the pipeline infrastructure.

3. To simulate the Slack notification channel, in a separate terminal, run `server.py` in `environments/60_local`:

   ```bash
   cd environments/60_local
   python server.py
   ```

3. In a new terminal, verify the email address to use as `SES_EMAIL_IDENTITY`:

   ```bash
   aws ses verify-email-identity --email-address example@example.com --region us-east-1 --endpoint-url=http://localhost:4566
   ```

4. Submit a zip file to the `ingest-datasets` bucket using the `put-object` command - this will trigger the pipeline:

   ```bash
   aws s3api --endpoint-url=http://localhost:4566 put-object --bucket ingest-datasets --key input/<filename>.zip --body <path/to/filename>.zip
   ```

