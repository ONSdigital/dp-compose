#!/usr/bin/env bash

brew install mkcert
sudo mkcert -install
sudo mkcert -cert-file "$DP_REPO_DIR/dp-compose/v2/provisioning/nginx/localhost.pem" -key-file "$DP_REPO_DIR/dp-compose/v2/provisioning/nginx/localhost-key.pem" localhost
