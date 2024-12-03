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

## Gotchas

In the `Makefile` of the stack there is a `DEFAULT_KEYS_FOLDER` variable that is set to point to the `static/keys` folder in the `dis-authentication-stub` repo.
Running the `make up` command will run also the `init` target in the `Makefile` and try to decrypt the files that are inside that folder.
If you run the `make up` command and you get an error saying that there are *no such files* in the folder, please change the value of the `ONS_DP_SRC_ROOT` variable (also located in the `Makefile`) to the root of where all your ONSdigital repos are.
