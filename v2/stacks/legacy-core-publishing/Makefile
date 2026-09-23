STACK_VARIANT ?= base
DEFAULT_ENV_FILE ?= default.env
LOCAL_ENV_FILE ?= local.env

ifeq ($(STACK_VARIANT),base)
	VARIANT_ENV_FILE :=
else ifeq ($(STACK_VARIANT),with-redirects)
	VARIANT_ENV_FILE := ./variants/with-redirects.env
else ifeq ($(STACK_VARIANT),with-cache)
	VARIANT_ENV_FILE := ./variants/with-cache.env
else ifeq ($(STACK_VARIANT),just-redirects)
	VARIANT_ENV_FILE := ./variants/just-redirects.env
else ifeq ($(STACK_VARIANT),)
	$(warning STACK_VARIANT not set, using base stack configuration)
	VARIANT_ENV_FILE :=
else
	$(error Unknown STACK_VARIANT '$(STACK_VARIANT)'. Valid values: base, with-redirects, with-cache, just-redirects)
endif

ifneq ($(VARIANT_ENV_FILE),)
	COMPOSE_ENV_FILES := $(DEFAULT_ENV_FILE),$(VARIANT_ENV_FILE),$(LOCAL_ENV_FILE)
endif

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

%-with-redirects:
	$(MAKE) $* STACK_VARIANT=with-redirects

%-with-cache:
	$(MAKE) $* STACK_VARIANT=with-cache

%-just-redirects:
	$(MAKE) $* STACK_VARIANT=just-redirects
