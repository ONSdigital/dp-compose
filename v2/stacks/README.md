# Stacks

This folder contains the different stacks. Please refer to the README of each of the stacks for more information on how to get started.

## General guidance

Unless stated otherwise in the stack specific READMEs, the following steps should generally apply:

1. Change to the stack directory:

   ```sh
   cd $sub_directory_under_stacks  # this varies per-stack
   cd homepage-web                 # for example
   ```

1. Check any prerequisites:

   ```sh
   make check
   ```

1. (Optionally) Ensure relevant repos are up-to-date:

   ```sh
   # optional
   # this will also clone any that are not yet cloned
   make pull
   ```

1. Start the stack:

   ```sh
   make up
   ```

1. Stop and destroy the stack after you have completed testing/development:

   ```sh
   # WARNING: this will remove local data from ephemeral databases, etc
   make clean
   ```

See [Using `make`](#using-make) for additional make targets and other information on using `make` to work with the stacks.

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
