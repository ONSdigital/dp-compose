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

.PHONY: generate-keys
generate-keys:
	$(eval keys := $(shell curl -s http://localhost:29500/jwt-keys | tr -d '"{}'))
	@grep -q "^JWT_VERIFICATION_PUBLIC_KEYS=" local.env \
		&& sed -i "s|^JWT_VERIFICATION_PUBLIC_KEYS=.*|JWT_VERIFICATION_PUBLIC_KEYS=$(keys)" local.env \
		|| echo "JWT_VERIFICATION_PUBLIC_KEYS=$(keys)" >> local.env

.PHONY: up-with-seed
up-with-seed: generate-keys
	$(MAKE) up
	$(MAKE) seed-topic-api
	$(MAKE) seed-permissions-api
