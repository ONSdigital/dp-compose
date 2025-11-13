# Cloud Flare Purge Stub

This directory contains a stub written in Python to simulate the Cloud Flare purge endpoint for local testing.
The stub will start with the rest of the dataset catalogue stack when running `make up` or `make up-with-seed`.

## Endpoints
The stub exposes the following endpoints:
```
/zones/{zone_id}/purge_cache
```
The endpoint being simulated, it accepts a POST request, with a json body that needs to contain one of the options as specificed in the [swagger.yml](swagger.yaml) spec.
`{zone_id}` is a path parameter that needs to be a string representing the zone ID and 32 characters long.
```
/health
```
A GET health check endpoint that returns a 200 OK response.

```
/rate_limit
```
An endpoint to toggle the rate limiting on so it only returns a rate limit error. It accepts a PUT request that toggles this on or off.

## Configuration
The stub can be configured with:
- `PORT`: port number to run the stub on
- `RATE_LIMIT_REQUESTS`: how many requests are allowed before rate limiting kicks in
- `RATE_LIMIT_PERIOD`: the time period in seconds the number of requests can be made before rate limiting kicks in
- `CLOUD_FLARE_AUTH_TOKEN`: the auth token expected

