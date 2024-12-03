# Stacks

This folder contains the different stacks. Please refer to the README of each of the stacks for more information on how to get started.

## General guidance

Unless stated otherwise in the stack specific READMEs, the following steps should generally apply:

1. Change to the stack directory:

   ```sh
   cd stacks/$stack_dir
   # e.g. 'cd stacks/auth'
   ```

2. Check any prerequisites:

   ```sh
   make check
   ```

3. (Optionally) Ensure relevant repos are up-to-date:

   ```sh
   # optional
   # this will also clone any that are not yet cloned
   make pull
   ```

4. Start the stack (will clone repos if necessary):

   ```sh
   make up
   ```

5. Stop and destroy the stack after you have completed testing/development:

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
- `make _list-repos`
   show the list of repos for the apps in the stack - used by `make clone`
- `make _list-services`
   show the list of all services/containers
- `make _list-apps`
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
  - `make _check-config` - check certain conditions are true
  - `make _check-env-vars` - warn if your shell is setting some relevant env vars
  - `make check-versions` - warn if specific versions of expected apps are missing
