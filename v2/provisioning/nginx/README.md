# NGINX

This directory contains configuration to run an nginx server as a proxy similar to how we do it in a remote environment.

Specifically this has been set up to allow the debugging of issues relaated to running with HTTPS locally.

To add to your stack you will need to:

1. Run the certificate generation:

    ```sh
    # only need to set this if you don't have it already
    export DP_REPO_DIR=/path/to/your/repos 
    # From repo root
    cd v2/scripts
    ./generate-certs.sh
    ```

    This will generate two `pem` files in the `v2/provisioning/nginx` folder. These are not to be committed.

1. Add the appropriate nginx to your `deps.yml` file:

    ```yml
    nginx:
        extends:
        file: ${PATH_MANIFESTS}/deps/nginx.yml
        service: nginx-web
    ```

1. `make up`

1. Access nginx on <https://localhost:8443>

## Proxied services

Currently the nginx boxes proxy to:

- `nginx-web` -> `dp-frontend-router`
- `nginx-publishing` -> `florence`
