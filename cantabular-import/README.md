### Cantabular Import Journey ###

## Requirements ##

Make sure you have the following repositories cloned to the same root directory
as `dp-compose` (this repository):

`dp-cantabular-server`

`dp-cantabular-api-ext`

`dp-cantabular-csv-exporter`

`dp-dataset-api`

`dp-import-api`

`dp-import-cantabular-dataset`

`dp-import-cantabular-dimension-options`

`dp-recipe-api`

`dp-api-router`

`dp-frontend-router`

`dp-publishing-dataset-controller`

`dp-frontend-dataset-controller`

`florence`

`zebedee`

Expects you to have environment variables `zebedee_root` and 
`SERVICE_AUTH_TOKEN` set in your local environment.

To use the `start-import` helpers scripts or analysis tools you will need
to set an environment variable called `FLORENCE_PASSWORD` to your local
florence login password for `florence@magicroundabout.ons.gov.uk`. Alternatively
you can directly edit `helpers/florence-token` to hard code your username
and password.

You will need to run the `import-recipes` script in `dp-recipe-api` when
first building the containers before running an import. Alternatively there 
is an `init-db.sh` script in this repositories `helpers` directory that runs 
both the recipes and datasets import scripts.

Also make sure you have setup the `dp-cantabular-server` and 
`dp-cantabular-api-ext` services by running `make setup` in each of their
root directories.

For the full-stack journey:

 You will need to run `make assets` in dp-frontend-router.
Assets generated using the  `-debug` flag won't work. 

You will also need to run `make generate-prod` in the dp-frontend-dataset-controller to generate the asset files.

For dp-frontend-dataset-controller you will need to generate assets using
`make generate-prod`

You will also need to make sure you have some
datasets into your Mongo collections. The easiest way to do this is to use the
import script in `dp-dataset-api`. Currently it can be found on it's own branch
`feature/import-script`. Alternatively there is an `init-db.sh` script in this
repositories `helpers` directory that runs both the recipes and datasets import
scripts.

For Florence to work you will need to have built npm modules and production assets.
You can do this by running `make node-modules` followed by `make generate-go-prod`.
This only needs to be done once (or until you generate debug assets). 

# Bring Up Cantabular Import Services #

The first time you run the import journey you will need to run:

`make start-privileged`

This will initialise the Go cache directories used by the containers to speed
up start-up time. You may also need to use this make target if you make code
changes that add more dependencies (go modules).

On subsequent runs you can use:

`make start`

# Bring Up Cantabular Import Services Detached (running in background) #

`make start-detached`

# Stop Services #

`make stop`

# Stop Services And Remove Containers #

`make down`

# Stop Services And Remove All Containers, Volumes and Networks #

`make clean`

# Restart Services #

`make restart`

# Recall Logs #

`make logs` or `./logs`

# Recall Logs For Specific Service #

`make logs t=<service-name>` or `./logs <service-name>`

## Notes ##

# Making Changes #

Go services will automatically rebuild upon detecting source file changes.

If you need to make adjustments to compose files etc, you can just
run `make start-detached` and docker-compose will automatically detect 
which services need rebuilding (no need to bring everything down first).

------------------
Files:

    run-cantabular-without-sudo.sh

are used by `cantabular-import/helpers/test-compose/test-compose.go` and are nedded at this level for it to bring up the cantabular containers.

------------------

# Adding New Services To Journey #

If you need to add a new service to the journey you need to take the following steps.

For a Golang service:

- Add `Dockerfile.local` and `reflex` file to service root directory. Copy from existing
examples and change instances of the service name in Dockerfile.local and the command
to be executed. This usually either `make debug` or `make debug-run`. Check the Makefile
and use the make target that runs the service using `go run` (as opposed to building an
executable and then running it). If there isn't such a target you will need to add it.
Again, use existing examples as a guide.
- Add `/go` to .`dockerignore` for service.
- Add `dp-my-service-name.yml` to `dp-compose/cantabular-import` directory. Follow existing
examples as a guide. Be sure to use the correct service name, port and environment variables
the service will need. These include those used when you would usually run the service (e.g.
`ENABLE_PRIVATE_ENDPOINTS=true`) and others that would usually use the service's default.
Most commonly these include URLs to other services which will need to be set to the
`http://service-name:port` from `http://localhost:port`. Also sometimes the `BIND_ADDR` will
default to `http://localhost:port` which will need to be set to simply `:port`.
- Add service yml file to relavent `.env` files in `dp-compose/cantabular-import`. The default
`.env` is for the full journey including front-end services, `env.backend` for back-end only
services and new `.env` files can be created for different journeys with different collections
of services as needed.
- If there are any external services (e.g. MongoDB, Kafka) the service depends on that are
not already included in the compose cluster add them to `deps.yml`. Be cognizant of which
services the new service is dependant on and add under the `depends_on` clause.
- Test the new service runs as expected and can be reached by other services and you're
good to go!
