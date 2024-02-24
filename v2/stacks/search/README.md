# Search Stack

This stack deploys the necessary services and dependencies for the search functionality.

The search stack uses elasticsearch to store some indexed data that can be queried via the search api.

You may run the stack in stand-alone mode, assuming you already have the data you need in elasticsearch.

Or you may run it with mappings to localhost, to obtain data from external sources (required if you need to re-index or run the extract-import pipeline with data available externally)

## Run with mappings

If you want to use data from en external source (e.g. Sandbox environment), you may use the backend-with-mappings stack, like so:

1- Set a valid service auth token for the environment you want to use. For example, you may check the environment's secrets in `dp-configs` and use a valid token:

```sh
export export SERVICE_AUTH_TOKEN=<valid_token>
```

2- Gain access to the environment you want to use. For example, you may login to sandbox environment:

```sh
aws sso login --profile dp-sandbox
```

3- Use the `dp` tool to ssh to `zebedee` and `dp-dataset-api` with port forwarding. For example:

```sh
# Zebedee
dp ssh sandbox publishing 1 -p 8082:10.30.138.93:26251
```

```sh
# Dataset API
dp ssh sandbox publishing 2 -p 22000:10.30.138.234:25681
```

Please, replace the publishing node, ip and port according to where the services are currently deployed when you run this. You can check this in [Consul](https://consul.dp.aws.onsdigital.uk/ui/eu/services)

4- Edit docker-compose config

Edit this stack's `.env` file and uncomment the following block:

```sh
# -- BACKEND WITH MAPPINGS -- Uncomment the following lines to run backend with mappings
#COMPOSE_FILE=deps.yml:backend-with-mappings.yml:frontend.yml
#ZEBEDEE_URL="http://host.docker.internal:8082"       
#DATASET_API_URL="http://host.docker.internal:22000" 
```

Ensure that the the blocks that begin

```sh
# -- FULL STACK (WEB) --
```

and

```sh
# -- FULL STACK (PUBLISHING) -- Uncomment the following lines to run full stack in publishing mode
```

are commented out.

5- Run the stack

```sh
make up
```

### Reindex

In order to populate elasticsearch, you may run the reindex script, and if you have followed the previous steps you will have access to the necessary external data.

Navigate to your `dp-search-api` repo location, edit the necessary config under `cmd/reindex/local.go`, and run:

```sh
make reindex
```

For more information on the reindex script, please check [search-api instructions](https://github.com/ONSdigital/dp-search-api/blob/develop/README.md#running-bulk-indexer).

### Extract-Import pipeline

When a dataset is published, the search extract-import kafka pipeline is triggered. You may emulate this in the search stack by using the command line tool to generate kafka messages.

WARNING: The pipeline assumes that an index with alias "ons" already exists, please make sure you have run the re-index script before trying the pipeline.

1- Navigate to your `search-data-extractor` location and then to `cmd/producer`

2- Run `go run main.go` and introduce the requested fields. When all the information is introduced a kafka message will be produced. For example:

```sh
--- [Send Kafka ContentPublished] ---
Please type the URI
$ /datasets/your-datasetid-here/editions/2021/versions/1/metadata
Please type the dataset type (legacy or datasets)
$ datasets
Please type the collection ID
$ collection-id
{"created_at":"2023-03-28T12:49:39.788994Z","namespace":"dp-search-data-extractor","event":"sending content-published event","severity":3,"data":{"contentPublishedEvent":{"URI":"datasets/your-datasetid-here/editions/2021/versions/1/metadata","DataType":"datasets","CollectionID":"collection-id","JobID":"","SearchIndex":"","TraceID":"054435ded"}}}
```

3- Check the docker-compose logs, starting with `search-data-extractor` to validate that the message is consumed and processed as expected.

## Run standalone

If you want to run a stand-alone search stack, without external dependencies, you may use the basic stack, like so:

1. Edit docker-compose config

   Edit this stack's `default.env` file and uncomment this block (by default this is uncommented):

   ```sh
   # -- FULL STACK (WEB) --
   COMPOSE_FILE=deps.yml:backend.yml:frontend.yml
   ```

   Ensure that the the blocks that begin

   ```sh
   # -- FULL STACK (PUBLISHING) -- Uncomment the following lines to run full stack in publishing mode
   ```

   and

   ```sh
   # -- BACKEND WITH MAPPINGS -- Uncomment the following lines to run backend with mappings
   ```

   are commented out.

1. Run the stack

   ```sh
   make up
   ```

## Run in Publishing mode

To run in publishing mode (mostly used to view Search via Florence) do the following:

1. Edit docker-compose config

   Edit this stack's `.env` file and uncomment this block:

   ```sh
   # -- FULL STACK (PUBLISHING) -- Uncomment the following lines to run full stack in publishing mode
   #COMPOSE_FILE=deps.yml:backend.yml:frontend.yml:publishing.yml
   #IS_PUBLISHING=true
   #ENABLE_AUDIT=true
   ```

   Ensure that the the blocks that begin

   ```sh
   # -- FULL STACK (WEB) --
   ```

   and

   ```sh
   # -- BACKEND WITH MAPPINGS -- Uncomment the following lines to run backend with mappings
   ```

   are commented out.

1. Ensure your service auth token is valid in your zebedee

   Check the /services directory to ensure there is a token there.

1. Run the stack

   ```sh
   make up
   ```

## Run with Reindex Pipeline

If you want to run a search stack, without external dependencies, including the reindex pipeline:

1. Edit docker-compose config

   Edit this stack's `default.env` file and uncomment this block (by default this is commented):

   ```sh
   # -- FULL STACK (WEB) + REINDEX --
   COMPOSE_FILE=deps.yml:backend.yml:frontend.yml:reindex.yml
   ```

1. Run the stack

   ```sh
   make up
   ```

## Gotchas

Some errors seen while adding new services that you can overcome

---

`dp-frontend-release-calendar` error 500 on a page similar to <http://localhost:20000/releases/uktotalpublicservicesproductivityestimates2013>. With the logs displaying:

```log
json: cannot unmarshal string into Go value of type zebedee.HomepageContent
```

Make sure your Zebedee authentication token is set (old authentication)

- Make a POST request to <http://localhost:8082/login>
- The body should take the form as:

```json
{
    "email": "florence@magicroundabout.ons.gov.uk",
    "password": "Your local florence/zebedee password"
}
```

- Add the response into your browser cookie as a key/value pair `access_token:{ResponseFromPOST}`

---

`dp-frontend-release-calendar` error 503, logs displaying that the app will not run and displaying similar to:

```log
no such module for github.com/kevinburke/go-bindata/go-bindata 
run go get github.com/kevinburke/go-bindata/go-bindata
```

- Delete your local files under the `.go/` (not source controlled) directory for the service
- Delete the offending image from the container
- Try again i.e. `make up`

---

GET request to <http://localhost:23200/v1/releases/legacy?url=/releases/uktotalpublicservicesproductivityestimates2013> returning a 500

Solution: set your authentication token

- Make a POST request to <http://localhost:8082/login>
- The body should take the form as:

```json
{
    "email": "florence@magicroundabout.ons.gov.uk",
    "password": "Your local florence/zebedee password"
}
```

- Add the response to the header of the GET request

`X-Florence-Token: {TheResponseFromThePOSTRequest}`
