# Include common make targets
include ../common.mk

MIGRATION_COLLECTION_NAME ?= migrationcollectionforjob1

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here

# Add any stack specific helper targets here

.PHONY: seed-topic-api
seed-topic-api: # Seed the topic API with the required topics for the migration job
	../../scripts/seed-topic-api.sh

.PHONY: seed-permissions-api
seed-permissions-api: # Seed the permissions API with the required permissions for the migration job
	../../scripts/seed-permissions-api.sh

.PHONY: up-with-seed
up-with-seed: ## Start the stack and seed the topic and permissions APIs
	$(MAKE) up
	$(MAKE) seed-topic-api
	$(MAKE) seed-permissions-api

.PHONY: remove-migration-collection
remove-migration-collection: # Remove the test migration collection from zebedee content store.
	rm $(zebedee_root)/zebedee/collections/$(MIGRATION_COLLECTION_NAME).json
	rm -r $(zebedee_root)/zebedee/collections/$(MIGRATION_COLLECTION_NAME)

.PHONY: reset
reset: # Reset the MongoDB databases and remove the test migration collection
	mongosh localhost:27017/migrations --file ../../provisioning/mongo/reset.js
	mongosh localhost:27017/datasets --file ../../provisioning/mongo/reset.js
	$(MAKE) remove-migration-collection

