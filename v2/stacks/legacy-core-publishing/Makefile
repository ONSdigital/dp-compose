# Include common make targets
include ../common.mk

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here
	@$(SCRIPTS_DIR)/zebedee-content.sh

# Add any stack specific helper targets here

.PHONY: seed-permissions-api
seed-permissions-api:
	../../scripts/seed-permissions-api.sh

.PHONY: up-with-seed
up-with-seed:
	$(MAKE) up
	$(MAKE) seed-permissions-api
