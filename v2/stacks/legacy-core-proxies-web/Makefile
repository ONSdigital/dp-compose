# Include common make targets
include ../common.mk

#COMPOSE_ENV_FILES ?= $(DEFAULT_ENV_FILE),$(LOCAL_ENV_FILE)

#REDIRECT_SERVICE ?= $(REDIRECT_PROXY),$(REDIRECT_API)

# Specifies the default environment variable file for the stack
#DEFAULT_ENV_FILE ?= default.env

# Specifies the local override environment variable file for the stack
#LOCAL_ENV_FILE ?= local.env

REDIRECT_PROXY ?= dis-redirect-proxy

REDIRECT_API ?= dis-redirect-api

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here
	@$(SCRIPTS_DIR)/zebedee-content.sh

# Add any stack specific helper targets here

# crude check to see if SERVICE is set and correct (needs to avoid recursion, hence using the yml files)
.PHONY: verify-redirect-service
verify-redirect-service: $(LOCAL_ENV_FILE)
	@[[ -z "$(SERVICE)" ]] && exit 0;							\
	for compose_env_f in $(shell sed 's/,/ /g' <<<"$(COMPOSE_ENV_FILES)"); do		\
		source $$compose_env_f;								\
	done;											\
	for compose_f in $$(sed 's/:/ /g' <<<"$$COMPOSE_FILE"); do				\
		for svc in $$(yq -r '.services | keys | .[]' $$compose_f); do			\
			[[ "$(SERVICE)" = $$svc ]] && exit 0;					\
		done;										\
	done;											\
	echo "\033[31m""service $(SERVICE) does not exist in stack. Failed to verify.\033[0m" >&2; \
	exit 4

.PHONY: redirects-up
redirects-up: init verify-redirect-service
	@echo "\033[34m""building, creating and starting containers...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose up -d $(REDIRECT_SERVICE)

.PHONY: redirects-down
redirects-down: verify-redirect-service colima-start
	@echo "\033[34m""stopping and removing containers and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down $(REDIRECT_SERVICE)

.PHONY: redirects-clean
redirects-clean: verify-redirect-service colima-start
	@echo "\033[34m""stopping and removing containers, associated volumes and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down -v $(REDIRECT_SERVICE)
