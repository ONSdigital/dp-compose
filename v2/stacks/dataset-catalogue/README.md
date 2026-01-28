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

This assumes that the locations of repositories on your system is in the same root as `dp-compose` or that you have an environment variable set for `$DP_REPO_DIR`

If that is not the correct location, you will be prompted to input a custom location for dp-topic-api or dp-permissions-api on your system.

Once the correct location is found, you should see something like:

   ```shell
Found dp-topic-api at {some-path}/dp-topic-api
mongosh localhost:27017/topics ./scripts/seed-database/index.js
creating collections

Seeding permissions API database...
Found dp-permissions-api at {some-path}/dp-permissions-api
   ```

For more information on working with the stack and other make targets, see the [general stack guidance](../README.md#general-guidance-for-each-stack).

## Using `localstack` for running Dataset Ingest pipelines locally

The `localstack` service can be used to run the Dataset Ingest pipelines locally. The `localstack` container is configured to use Terraform version 1.10.0. You can manage different versions of Terraform using `tfenv`, which can be installed via `brew`:

   ```bash
   brew install tfenv
   tfenv install 1.10.0
   ```

   We also recommend that you use `pyenv` to manage your Python environment:

   ```bash
   brew install pyenv
   pyenv install 3.13.2
   ```

To interact with the Dataset Ingest pipelines, run `make up-with-seed` from the `dp-compose/v2/stacks/dataset-catalogue` directory, then run the following commands in the [`dis-infra-data-pipeline-stack`](https://github.com/ONSdigital/dis-infra-data-pipeline-stack) repo:

1. Create a Python virtual environment (the instructions below assume that you are using VS Code):

   - Open the Command Palette (`Cmd+Shift+P`)
   - Search for and select `Python: Create Virtual Environment`
   - Select `Venv`
   - Select the `Pyenv` installation of Python 3.13.2

   From the root directory of the repo, run the following commands:

   ```bash
   pip install poetry
   source .venv/bin/activate
   make install
   ```

   This will install the `terraform-local` package, which is required to apply the pipeline infrastructure. 

2. Navigate to `environments/60_local` and run:

   ```bash
   tflocal init
   tflocal apply
   ```

   Enter `yes` to apply the pipeline infrastructure in `localstack`.

   If you encounter the following error, run `export S3_HOSTNAME=localhost` before running `tflocal init`:

   ```
   Error: creating S3 Bucket (ingest-datasets) Notification: operation error S3: PutBucketNotificationConfiguration, https response error StatusCode: 0, RequestID: , HostID: , request send failed, Put "http://s3.localhost.localstack.cloud:4566/ingest-datasets?notification=": dial tcp: lookup s3.localhost.localstack.cloud: no such host
   ```

3. In your `.aws` directory, add the following to the `credentials` file:

   ```
   [default]
   aws_access_key_id=test
   aws_secret_access_key=test
   aws_session_token=test
   ```

4. To simulate the Slack notification channel, in a separate terminal, run `server.py` in `environments/60_local`:

   ```bash
   cd environments/60_local
   python server.py
   ```

   You can also view the logs for the `localstack` container by running:

   ```bash
   docker logs -f <name-of-localstack-container>
   ```

5. In a new terminal, verify the email address `example@example.com` to use as `SES_EMAIL_IDENTITY`:

   ```bash
   aws ses verify-email-identity --email-address example@example.com --region us-east-1 --endpoint-url=http://localhost:4566
   ```

6. Submit a zip file to the `ingest-datasets` bucket using the `put-object` command - this will trigger the pipeline:

   ```bash
   aws s3api --endpoint-url=http://localhost:4566 put-object --bucket ingest-datasets --key input/<filename>.zip --body <path/to/filename>.zip
   ```

   Check the terminal where `server.py` is running to view the Slack notifications.

   To verify that the zip file has moved to the correct folder (`processed` or `failed`), run:

   ```bash
   aws s3api --endpoint-url=http://localhost:4566 list-objects --bucket ingest-datasets
   ```
