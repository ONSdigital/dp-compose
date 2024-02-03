# Specifies the service upon which to act, by default this is all services
SERVICE ?=

# Specifies the default environment variable file for the stack
DEFAULT_ENV_FILE ?= default.env

# Specifies the local override environment variable file for the stack
LOCAL_ENV_FILE ?= local.env

# Specifies the environment variables files for docker compose to use.
# See the docs for more details:
# https://docs.docker.com/compose/environment-variables/envvars/#compose_env_files
COMPOSE_ENV_FILES ?= $(LOCAL_ENV_FILE),$(DEFAULT_ENV_FILE)

.PHONY: up
up: $(LOCAL_ENV_FILE)
	@echo "building, creating and starting containers..."
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose up -d $(SERVICE)

.PHONY: down
down: $(LOCAL_ENV_FILE)
	@echo "stopping and removing containers and networks..."
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down $(SERVICE)

.PHONY: clean
clean: $(LOCAL_ENV_FILE)
	@echo "stopping and removing containers, associated volumes and networks..."
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down -v $(SERVICE)

.PHONY: start
start: $(LOCAL_ENV_FILE)
	@echo "starting containers..."
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose start $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: stop
stop: $(LOCAL_ENV_FILE)
	@echo "stopping containers..."
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose stop $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: logs
logs: $(LOCAL_ENV_FILE)
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose logs -f $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: ps
ps: $(LOCAL_ENV_FILE)
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose ps $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: health
health: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) ../../scripts/health.sh

.PHONY: base-init
base-init: clone $(LOCAL_ENV_FILE)

.PHONY: clone
clone:
	@../../scripts/clone.sh

$(LOCAL_ENV_FILE): |../$(LOCAL_ENV_FILE).tmpl
	cp ../$(LOCAL_ENV_FILE).tmpl $(LOCAL_ENV_FILE)
