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

.PHONY: ps start stop config
ps start stop config: $(LOCAL_ENV_FILE)
	@echo "$@ containers..." >&2
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose $@ $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: countainer-id
countainer-id: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker ps --format='{{ .ID }} {{ .Names }}' | awk '/$(SERVICE)/{print $$1}'

.PHONY: attach
attach: $(LOCAL_ENV_FILE)
	@c_id=$$(make countainer-id);								\
		if [[ -z $$c_id ]]; then echo Could not get container-id >&2; exit 3; fi;	\
		if [[ $$c_id =~ [[:space:]] ]]; then echo Use more specific SERVICE, got IDs $$c_id >&2; exit 4; fi;	\
		echo "Attaching to container '$$c_id' for $(SERVICE)" >&2;			\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker exec -it $$c_id bash

.PHONY: logs
logs: $(LOCAL_ENV_FILE)
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose logs -f $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: health
health: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) ../../scripts/health.sh

.PHONY: base-init
base-init: clone $(LOCAL_ENV_FILE)

.PHONY: clone
clone:
	@../../scripts/clone.sh

.PHONY: pull
pull:
	@../../scripts/clone.sh pull

list-repos:
	@make config | yq -r '.services | to_entries | .[].value."x-repo-url" | select(.)' | sort -u

$(LOCAL_ENV_FILE): |../$(LOCAL_ENV_FILE).tmpl
	cp ../$(LOCAL_ENV_FILE).tmpl $(LOCAL_ENV_FILE)
