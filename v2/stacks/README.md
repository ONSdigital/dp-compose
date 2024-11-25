# Stacks

This folder contains the different stacks. To run a stack you have to go to its corresponding folder where the stack is defined:

```sh
cd $chosen_stack_name_here
# for example, relative to this 'stacks' directory
cd auth
```

## Initialisation

Please make sure you have cloned the required repositories as siblings of `dp-compose` (see [`make clone`](#make-targets) for help with this).

Some stacks require an initialisation step, please check the corresponding [stack instructions](#current-stacks) in that case.

### Run with make targets

A `Makefile` is provided for each stack, so you can run the corresponding `make` command. For example:

```sh
# inside the given stack directory
make up      # bring the stack up
```

or, in the same directory:

```sh
make clean   # bring the stack down and remove it from docker
```

See [using make](#using-make), below, for more information on the available `make` targets.

### Environment

Check the `local.env` file and change it for your development requirements - you might need to point to local services running in an IDE, for example.

You can override any env var defined by any manifest used by the stack, any value that you override in `local.env` will be picked up by all the manifests used by the stack.

Here is a comprehensive list of env vars you can override:

- Secret values, which **MUST NOT** be committed:

   ```sh
   # get from cognito: sandbox-florence-users
   AWS_COGNITO_USER_POOL_ID
   # get from within pool - App Integration: App client: dp-identity-api
   AWS_COGNITO_CLIENT_ID
   # get from within pool - App Integration: App client: dp-identity-api
   AWS_COGNITO_CLIENT_SECRET

   # Below values from the aws login-dashboard:
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   AWS_SESSION_TOKEN
   ```

   To get the above values do the following:

  - login to the AWS [console](https://ons.awsapps.com/start#/)
  - click on `Command line or programmatic access`
  - click on `Option 1: Set AWS environment variables (Short-term credentials)`
  - copy the highlighted values, paste them into the `local.env` file

   Note that the `AWS_SESSION_TOKEN` is only valid for 12 hours. Once the token has expired, you would need to stop the stack, retrieve and set new credentials before running the stack again.

- Flags (true or false values)

   ```sh
   AUTHORISATION_ENABLED
   IS_PUBLISHING
   ENABLE_PRIVATE_ENDPOINTS
   ENABLE_AUDIT
   ENABLE_TOPIC_API
   ENABLE_FILES_API
   ENABLE_RELEASE_CALENDAR_API
   DEBUG
   ENABLE_CENSUS_TOPIC_SUBSECTION
   ENABLE_NEW_NAVBAR
   FILTER_FLEX_ROUTES_ENABLED
   ENABLE_PERMISSION_API
   ENABLE_NEW_SIGN_IN
   ENABLE_DATASET_IMPORT
   FORMAT_LOGGING
   ENABLE_PERMISSIONS_AUTH
   ```

- Other vars

   ```sh
   HEALTHCHECK_INTERVAL
   TMPDIR
   ```

- Service URLs

   ```sh
   # for local development you may use: http://host.docker.internal: (note: MacOS only!)
   # if your stack uses an HTTP stub container (http-echo), then you can use `http-echo:5678` as host for any URL service that you want to mock.
   # e.g. MOCKED_SERVICE_URL=http://http-echo:5678

   # Core
   API_ROUTER_URL
   FRONTEND_ROUTER_URL
   ZEBEDEE_URL
   FLORENCE_URL
   BABBAGE_URL

   # Auth
   PERMISSIONS_API_URL
   IDENTITY_API_URL

   # Backend
   FILES_API_URL
   UPLOAD_API_URL
   DOWNLOAD_SERVICE_URL
   DATASET_API_URL
   IMAGE_API_URL
   FILTER_API_URL
   DATASET_API_URL
   RECIPE_API_URL
   IMPORT_API_URL
   TOPIC_API_URL
   RELEASE_CALENDAR_API_URL
   SEARCH_API_URL

   # frontend
   SIXTEENS_URL
   DATASET_CONTROLLER_URL
   HOMEPAGE_CONTROLLER_URL
   DATASET_CONTROLLER_URL
   ```

## Current stacks

### General guidance for each stack

Unless stated below, for each stack listed, the following is assumed:

1. You are in the given stack directory

   ```sh
   cd $sub_directory_under_stacks  # this varies per-stack
   cd homepage-web                 # for example
   ```

1. You have checked any prerequisites

   ```sh
   make check
   ```

1. You may want to get the relevant repos uptodate

   ```sh
   # optional
   # this will also clone any that are not yet cloned
   make pull
   ```

1. You have started the docker stack

   ```sh
   make up
   ```

1. When you have completed testing/development (see below, per stack), you may stop all containers and clean the environment:

   ```sh
   # WARNING: this will remove local data from ephemeral databases, etc
   make clean
   ```

See [Using `make`](#using-make) for additional make targets and other information on using `make` to work with the stacks.

### Homepage publishing

Deploys a stack for the home page in Publishing mode.

Stack root folder is [`homepage-publishing`](./homepage-publishing/).
See the [general guidance, above](#general-guidance-for-each-stack), first, then:

1. Open your browser and check you can see the florence website: `http://localhost:8081/florence`

2. Log in to florence and perform the publish journey

### Static files

Stack root folder is either

- [`static-files-with-auth`](./static-files-with-auth/)
- [`static-files`](./static-files/)

See the [general guidance, above](#general-guidance-for-each-stack), first.

### Search

Stack root folder is [`search`](./search/).
See the [general guidance, above](#general-guidance-for-each-stack), first.

## Using `make`

We use `make` to allow quick/easy use of `docker` and `docker-compose` commands
with the correct setup (`make` sets the env vars that `docker` needs) for the given stack.

### Make options

Some optional general *make variables* can be used:

- `make ... SERVICE=....`

   By default, most make targets will act on all services (e.g. `make up`), but you can limit the action
   to a given service if you specify `SERVICE` e.g. `make up SERVICE=dp-api-router`

   Some targets will use `SERVICE` as a prefix and act on all matching services.

- `make ... ENABLE_MULTI=1`

   Some make actions/targets will fail if SERVICE does not specify a single service, e.g. `make clean-image`
   whereas if you set `ENABLE_MULTI` it will act on more than one: e.g. `make clean-image ENABLE_MULTI=1`

- there are some variables specific to `make logs`, see below for those.

### Make targets

- `make ps`
    equivalent to `docker-compose ps` (show running containers)
- `make ps-docker`
    equivalent to `docker ps` (show running containers)
- `make config`
   equivalent to `docker-compose config` (show single YAML describing the stack)
- `make up` / `make down`
   bring the container(s) (for the stack or `SERVICE`) up/down
- `make health`
   query the health of each service
- `make clone` / `make pull` / `make git-status`
   `git clone/pull/status` all apps used by this stack
- `make prep`
   apply initialisation files against repos in this stack
   (e.g. patches to source or scripts to prep the repos)
- `make list-repos`
   show the list of repos for the apps in the stack - used by `make clone`
- `make list-services`
   show the list of all services/containers
- `make list-apps`
   show the list of apps (a subset of *services* that have a 'x-repo-url' field)
- `make logs LOGS_TAIL=1 LOGS_TIMESTAMP=1 LOGS_NO_PREFIX=1`
   show the logs for the matching services (optionally with tailing, timestamp and/or container-prefixed)
- `make attach`
   attach to a running container (i.e. get a shell)
- `make clean`
- `make clean-image` - remove container images
- `make refresh`
   a shortcut for `make down clean-image up`
- `make check` comprises
  - `make check-config` - check certain conditions are true
  - `make check-env-vars` - warn if your shell is setting some relevant env vars
  - `make check-versions` - warn if specific versions of expected apps are missing

## Example on how to debug a Go application running in docker

This example will show how we can debug `dp-identity-api` when we run the auth stack.

- Replace the contents of the `Dockerfile.local` file (in the `dp-identity-api`) with the following code

```sh
FROM golang:1.21-bullseye AS base

ENV GOCACHE=/go/.go/cache GOPATH=/go/.go/path TZ=Europe/London

RUN GOBIN=/bin go install github.com/cespare/reflex@v0.3.1
RUN GOBIN=/bin go install github.com/go-delve/delve/cmd/dlv@latest
RUN PATH=$PATH:/bin

ENV PATH=$PATH
# Clean cache, as we want all modules in the container to be under /go/.go/path
RUN go clean -modcache

COPY . .
RUN go build -gcflags="all=-N -l" -o /go/server
ENTRYPOINT ["dlv", "--log", "--listen=:2345", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "./server"]
```

- Change the `BuildTime`, `GitCommit`, `Version` variables in the `dp-identity-api/main.go` file and assign them a string literal value (for example `"1"`).
- Remove the `command` section of the `dp-compose/v2/manifests/core-ons/dp-identity-api.yml` file.
- Expose the port on which the debugging server is running on by adding `- "2345:2345"` (in this example is 2345) to the ports section of the `dp-compose/v2/manifests/core-ons/dp-identity-api.yml` file.
- In IntelliJ IDE or Goland IDE open `dp-identity-api` repo and on the menu bar click `Run->Edit Configurations...`. On the popup window in the top left corner click the `+` button and choose `Go Remote` (the default port should be 2345). Put also a useful name next to the `Name:` label. Hit `Apply` and `Ok`.
  ![Run/Debug Configurations screenshot](../../v2/assets/screenshot.png?raw=true "Run/Debug Configurations")
- Run the auth stack if it is not running already (make sure to remove dp-identity-api image first) or if you are already running it, run `make refresh SERVICE=dp-identity-api`.
- Put your breakpoints in the code that you want to debug.
- On the menu bar click `Run->Debug Name-that-you-chose`.
