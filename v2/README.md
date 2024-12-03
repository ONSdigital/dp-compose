# v2

Motivation for v2 is to create a consistent structure that allows our teams to easily stand up a local development environment in a stable, reliable and repeatable way.

Eventually we plan to move this v2 directory up to root and remove/refactor all other directories/files to provide a single source of truth.

## Getting started

### Prerequisites

The scripts in this repo require a few tools to be installed before running them.

1. If you haven't already, then [install `brew`](https://brew.sh/):

   ```shell
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. We provide a Brewfile to install the dependencies, but this can cause issues if you have manually installed any of the tools rather than using brew. Please review the [Brewfile](./Brewfile) to see what will be installed and comment out any items you have manually installed outside of brew before continuing.
3. Install the dependencies:

   ```shell
   brew bundle --no-lock --file=./Brewfile
   ```

4. (Optional) It might be a good idea to clean the Docker environment - purge all containers/volumes/images and start fresh. Any issues then definitely give this a go first.

:warning: We require all repos listed in the [manifests](manifests) to be cloned in the same parent directory as this repo (i.e. `../../`). If you have already cloned any of these repos to a different location it is recommended that you either delete or move them before continuing.

### Usage

Each stack is independent from the other, and `make` should be run from the root of the stack you want to use.

Unless stated otherwise in the stack specific READMEs, the following steps generally apply:

1. If you already have another stack running, you should stop it before starting a new stack to prevent port collisions and resource exhaustion:

   ```sh
   cd stacks/$running_stack_dir
   make stop
   ```

2. Change to the stack directory:

   ```sh
   cd stacks/$stack_dir
   # e.g. 'cd stacks/auth'
   ```

3. Check any prerequisites:

   ```sh
   make check
   ```

4. (Optionally) Ensure relevant repos are up-to-date:

   ```sh
   # optional
   # this will also clone any that are not yet cloned
   make pull
   ```

5. Start the stack (will clone repos if necessary):

   ```sh
   make up
   ```

6. Destroy the stack after you have completed testing/development:

   ```sh
   # WARNING: this will remove local data from ephemeral databases, etc
   make clean
   ```

See [Using `make`](#using-make) for additional make targets and other information on using `make` to work with the stacks.

## Using `make`

We use `make` to allow quick/easy use of `docker` and `docker-compose` commands
with the correct setup (`make` sets the env vars that `docker` needs) for the given stack.

### Make options

Make allows you to pass variables. These variables can be passed from the command line and the order does not matter.

For example, all of the following are valid:

```shell
SERVICE=my-service make up
# OR
make up SERVICE=my-service
# OR
make SERVICE=my-service up
```

See [Make targets](#make-targets) below for details of which variables you can use with each target.

### Make targets

The following are the common targets shared by all stacks that are intended for direct use:

Make target | Description | Variables
------------|-------------|----------
`attach`    | Attach to a running container (i.e. get a shell) | The service to attach to can be specified using the `SERVICE` variable.
`check` | Performs basic checks on your env vars, dependency versions and the stack config | N/A
`clean` | Stops and removes containers, associated volumes and networks for the stack | A service to clean can be specified using the `SERVICE` variable.
`clean-image` | Remove container images for the specified service | It is required to either pass the `SERVICE` to remove images for or set `ENABLE_MULTI=1` to remove all images (N.B. this is not limited to the current stack and will attempt to remove all of your images)
`clone` | Clone all apps used by this stack | Can be limited to a specific service by passing the `SERVICE` variable.
`colima-start` | Start colima docker runtime | N/A
`colima-stop` | Stop colima docker runtime | N/A
`config` | Output stack docker compose config as YAML. Equivalent to `docker-compose config` | Can be limited to a specific service by passing the `SERVICE` variable.
`down` - DONE
`git-status` - DONE
`health` - DONE
`init` - DONE
`logs` - DONE
`prep` - DONE
`ps` | List running docker containers for the current stack. Equivalent to `docker-compose ps`. | The list can be restricted to a single service by passing the `SERVICE` variable.
`ps-docker` | List all running containers (not limited to the current stack). Equivalent to `docker ps`. |
`pull` - DONE
`refresh` -
`restart` - DONE
`start` - DONE
`stop` - DONE
`total-purge` - DONE
`up` - DONE

Some additional internal targets also exist to be called internally by other targets. You can think of these as private methods and are not intended for direct use:

* `_base-init`
* `_check-config`
* `_check-env-vars`
* `_check-repos`
* `_check-versions`
* `_container-id`
* `_get-repository-name`
* `_image-id`
* `_list-apps`
* `_list-env-vars`
* `_list-repos`
* `_list-services`
* `_verify-service`
* `local.env`

## Structure

The required configs and scripts have been structured as follows:

![structure](structure.png)

### manifests

Contains docker compose config `yml` files for each service that is required by any of the stacks. These configurations are stack agnostic and define all the necessary env vars to run the services in any possible configuration that might be required by any stack. Each env var has a sensible default value, which will be used if not provided by the stack, and usually corresponds to the default value in the service config.

The files are organised in subfolders according to their type:

- core-ons: Core services implemented by ONS
- deps: Dependencies, not implemented by ONS, used by ONS services

### stacks

Contains definitions for each stack, including config overrides and docker compose extension files. Each stack should be independent from the other stacks, but they should extend the required manifests, overwriting any env vars required by the stack to work as expected.

Each sub-folder corresponds to a particular stack and contains at least:

- `{stack}.yml`: Extended docker-compose file which uses the manifests for required services.
  - More information [here](https://docs.docker.com/compose/extends/)
- `default.env` and `local.env`: With the environmental variables required to override the default config for the services in the stack (`local.env` is git-ignored because it contains your local, and possibly sensitive, env vars)
  - More information [here](https://docs.docker.com/compose/environment-variables/#using-the---env-file--option)

#### stack env files

Note that each `*.env` file should be used only to override required env vars for that particular stack and check that any compulsory env vars for the stack are set.

For example, the following `default.env` file:

- checks for compulsory env vars
- defines relative paths to shared manifests and provisioning scripts
- overwrites default values used by the stack and/or extended manifests
- configures docker compose for the stack

```shell
# -- Compulsory env vars validation --
AWS_COGNITO_USER_POOL_ID=${AWS_COGNITO_USER_POOL_ID:?please define a valid AWS_COGNITO_USER_POOL_ID in your local system, get from cognito, e.g. sandbox-florence-users}
AWS_COGNITO_CLIENT_ID=${AWS_COGNITO_CLIENT_ID:?please define a valid AWS_COGNITO_CLIENT_ID in your local system, get from within pool}
AWS_COGNITO_CLIENT_SECRET=${AWS_COGNITO_CLIENT_SECRET:?please define a valid AWS_COGNITO_CLIENT_SECRET in your local system, get from within pool}

# -- Paths --
PATH_MANIFESTS="../../manifests"
PATH_PROVISIONING="../../provisioning"

# -- Stack config env vars that override manifest defaults --
IS_PUBLISHING="false"

# -- Docker compose vars --
COMPOSE_FILE=deps.yml:core-ons.yml
COMPOSE_PATH_SEPARATOR=:
COMPOSE_PROJECT_NAME=home-web
COMPOSE_HTTP_TIMEOUT=120
```

Any changes to these stack defaults - that only affect your individual circumstances - should go into the `local.env` file in the given stack.

### provisioning

Contains scripts and files to set the initial state required for stacks to work. This include things like database collections, content, etc.

## Kafka

Some stacks use KRaft mode, which is an [early release](https://github.com/apache/kafka/blob/6d1d68617ecd023b787f54aafc24a4232663428d/config/kraft/README.md).
