# NGINX

This directory contains configuration to run an nginx server as a proxy similar to how we do it in a remote environment.

Specifically has been setup to allow for running with HTTPS locally to debug issues related to this.

To add to your stack you will need to:

1. Run the certificate generation:

```sh
# From repo root
cd v2/scripts
./generate-certs.sh
```

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
