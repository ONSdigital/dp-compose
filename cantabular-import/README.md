### Cantabular Import Journey ###

## Requirements ##

Make sure you have the following repositories cloned to the same root directory
as `dp-compose` (this repository):

`babbage`

`florence`

`the-train`

`zebedee`

`dp-api-router`

`dp-cantabular-api-ext`

`dp-cantabular-csv-exporter`

`dp-cantabular-dimension-api`

`dp-cantabular-filter-flex-api`

`dp-cantabular-metadata-exporter`

`dp-cantabular-server`

`dp-cantabular-xlsx-exporter`

`dp-download-service`

`dp-dataset-api`

`dp-frontend-router`

`dp-import-api`

`dp-import-cantabular-dataset`

`dp-import-cantabular-dimension-options`

`dp-recipe-api`

# Bring Up Cantabular Import Services #

Expects you to have environment variables `zebedee_root` and
`SERVICE_AUTH_TOKEN` set in your local environment

Note that you will need the Mongo shell
(see https://github.com/ONSdigital/dp-recipe-api/tree/develop/import-recipes#prerequisites)
and Mongo tools
(see https://github.com/ONSdigital/dp-dataset-api/tree/develop/import-script#prerequisites)
to run the scripts below

You will need to run the `import-recipes` script in `dp-recipe-api` when
first building the containers, while the stack is running but before running an import.
See the README here:
https://github.com/ONSdigital/dp-recipe-api/tree/develop/import-recipes

:bulb: **Note:** *As an alternative to running the `import-recipes` script on its own, there is
an `init-db.sh` script in this repository's `helpers` directory that runs both the recipes
and datasets import scripts (which you will need later).*

```
import-recipes % ./import-recipes.sh mongodb://localhost:27017
. . .
BulkWriteResult({
	"writeErrors" : [ ],
	"writeConcernErrors" : [ ],
	"nInserted" : 58,
	"nUpserted" : 0,
	"nMatched" : 0,
	"nModified" : 0,
	"nRemoved" : 0,
	"upserted" : [ ]
})
bye
```

Also make sure you have setup the `dp-cantabular-server` and
`dp-cantabular-api-ext` services by running `make setup` in each of their
root directories.

- dp-cantabular-server: https://github.com/ONSdigital/dp-cantabular-server
- dp-cantabular-api-ext: https://github.com/ONSdigital/dp-cantabular-api-ext

For the full-stack journey:

You will need to run `make assets` in dp-frontend-router. Assets generated using the  `-debug` flag won't work.

You will also need to run `make generate-prod` in the dp-frontend-dataset-controller to generate the asset files.

You will also need to make sure you have some datasets into your Mongo collections.
To do this there is an import script: `dp-dataset-api/import-script/import-script.sh`.

:bulb: **Note:** *Alternatively there is an `init-db.sh` script in this repositories
`helpers` directory that runs both the recipes and datasets import scripts.*

```
import-script % ./import-script.sh
2022-01-24T15:38:36.576+0000	connected to: localhost
2022-01-24T15:38:36.597+0000	imported 1 document
2022-01-24T15:38:36.613+0000	connected to: localhost
2022-01-24T15:38:36.628+0000	imported 1 document
2022-01-24T15:38:36.643+0000	connected to: localhost
2022-01-24T15:38:36.657+0000	imported 1 document
2022-01-24T15:38:36.674+0000	connected to: localhost
2022-01-24T15:38:36.724+0000	imported 533 documents
```
For Florence to work you will need to have built npm modules and production assets.
You can do this by running `make node-modules` followed by `make generate-go-prod`.
This only needs to be done once (or until you generate debug assets).

:bulb: `make node-modules` may take a long time to run (e.g. 7 minutes) and may appear to
stop responding but may still complete successfully. `make generate-go-prod` completes
very quickly.

# Bring up Cantabular Import Services #

`make start`

(note: we use `sudo` to prevent docker having issues accessing the `GOCACHE`
volume it creates. `sudo` requires the `-E` in order to preserve existing
environment variables)

# Bring up Cantabular Import Services Detached (running in background) #

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

    get-florence-token.sh

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
