# Include common make targets
include ../common.mk

# Specifies the root of where all your ONSdigital repos are
ONS_DP_SRC_ROOT ?= $(shell git rev-parse --show-cdup)..
# Specifies the default folder where the keys are stored in
DEFAULT_KEYS_FOLDER ?= $(ONS_DP_SRC_ROOT)/dis-authentication-stub/static/keys

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here
	gpg -d $(DEFAULT_KEYS_FOLDER)/public.key.asc > $(DEFAULT_KEYS_FOLDER)/public.key
	gpg -d $(DEFAULT_KEYS_FOLDER)/private.key.asc > $(DEFAULT_KEYS_FOLDER)/private.key
	gpg -d $(DEFAULT_KEYS_FOLDER)/jwt-keys.json.asc > $(DEFAULT_KEYS_FOLDER)/jwt-keys.json

# Add any stack specific helper targets here
