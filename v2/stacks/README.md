# Stacks

This folder contains definitions for the different stacks. To run a stack you have to go to its corresponding folder:

```sh
cd stacks/<stack_name>
```

### Initialisation:

Please make sure you have cloned the required repositories as siblings of dp-compose (or you override the corresponding `ROOT_{service}` env var).

Some stacks require an initialisation step, please check the corresponding stack instructions in that case.


### Run with default docker compose commands:

Then just standard Docker compose commands: e.g.:

- to start detached: `docker compose up -d`, or with the alias: `dpc up -d`

- to get logs for a service: `docker compose logs -f dp-files-api`, or: `dpc logs dp-files-api`

### Run with default docker compose commands:

Alternatevily, if a Makefile is provided for the stack, you can run the corresponding `make` command. For example:

```sh
make start-detached
```

```sh
make clean
```

### Environment

Check the `.env` file and change it for your development requirements - you might need to point to local services running in an IDE for example.

You can override any env var defined by any manifest used by the stack, any value that you override in `.env` will be picked up by all the manifests used by the stack.
Here is a comprehensive list of env vars you can override:

- Secret values, which MUST NOT be committed:
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

To get the above values do the following:
- login to the AWS [console](https://ons.awsapps.com/start#/)
- click on `Command line or programmatic access`
- click on `Option 1: Set AWS environment variables (Short-term credentials)`
- copy the highlighted values

Note that the AWS_SESSION_TOKEN is only valid for 12 hours. Once the token has expired you would need to stop the stack, retrieve and set new credentials before running the stack again.
# This should be your locally generated token by Zebedee
SERVICE_AUTH_TOKEN
```

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

- Service roots:

```sh
# each manifest service points to the root of the corresponding repostitory, with a default value of (../../../../<repo>

# Example:
ROOT_API_ROUTER
(default is ../../../../dp-api-router)
```

## Homepage web

Deploys a stack for the home page and census hub in web mode.

1) The first time that you run it, you will need to generate the assets and have the zebedee content. It also assumes that you have defined `zebedee_root` env var in your system.

2) Go to the stack root folder

```sh
cd homepage-web
```

3) Start the docker stack

```sh
make start-detached
```

3) Open your browser and check you can see the home page: `localhost:24400`

3) Check you can see the census hub page: `localhost:24400/census`

4) You may stop all containers and clean the environment when you finish:

```sh
make clean
```


## Homepage publishing

Deploys a stack for the home page in publishing mode.

1) The first time that you run it, you will need to generate the assets and have the zebedee content. It also assumes htat you have defined `zebedee_root` env var in your system.

2) Go to the stack root folder

```sh
cd homepage-publishing
```

3) Start the docker stack

```sh
make start-detached
```

3) Open your browser and check you can see the florence website: `http://localhost:8081/florence`

4) Log in to florence and perform a publish journey

5) You may stop all containers and clean the environment when you finish:

```sh
make clean
```

## Static files

1) Start the docker stack

```sh
make start-detached
```

2) You may stop all containers and clean the environment when you finish:

```sh
make clean
```


## Search

1) Start the docker stack:

```sh
make start-detached
```

2) Stop the docker stack, removing containers, without removing the data:

```sh
make down
```

3) You may stop all containers and clean the environment when you finish. WARNING: this will remove local data:

```sh
make clean
```

More information in [search stack readme](./search/README.md)


## Static files with auth

1) Start the docker stack

```sh
make start-detached
```

2) You may stop all containers and clean the environment when you finish:

```sh
make clean
```
