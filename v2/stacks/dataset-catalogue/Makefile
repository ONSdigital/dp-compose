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
