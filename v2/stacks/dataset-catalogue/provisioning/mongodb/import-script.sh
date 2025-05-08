#!/usr/bin/env bash

mongoimport --host 127.0.0.1:27017 --db datasets --collection datasets --file /docker-entrypoint-initdb.d/datasets.json 
mongoimport --host 127.0.0.1:27017 --db datasets --collection editions --file /docker-entrypoint-initdb.d/editions.json
mongoimport --host 127.0.0.1:27017 --db datasets --collection instances --file /docker-entrypoint-initdb.d/instances.json
mongoimport --host 127.0.0.1:27017 --db datasets --collection dimension.options --file /docker-entrypoint-initdb.d/dimension.options.json
mongoimport --host 127.0.0.1:27017 --db datasets --collection versions --file /docker-entrypoint-initdb.d/versions.json
mongoimport --host 127.0.0.1:27017 --db bundles --collection bundles --file /docker-entrypoint-initdb.d/bundles.json
