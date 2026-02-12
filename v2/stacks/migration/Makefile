# Include common make targets
include ../common.mk

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here

# Add any stack specific helper targets here

.PHONY: seed-topic-api
seed-topic-api:
	../../scripts/seed-topic-api.sh

.PHONY: seed-permissions-api
seed-permissions-api:
	../../scripts/seed-permissions-api.sh

.PHONY: up-with-seed
up-with-seed:
	$(MAKE) up
	$(MAKE) seed-topic-api
	$(MAKE) seed-permissions-api

.PHONY: reset
reset:
	mongosh localhost:27017/migrations --file ../../provisioning/mongo/reset.js
	mongosh localhost:27017/datasets --file ../../provisioning/mongo/reset.js

