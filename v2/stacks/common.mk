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

SCRIPTS_DIR ?= ../../scripts

# by default, do not act on more than one (app, image, etc)
MULTI_OK ?=

LOGS_TIMESTAMP ?=
LOGS_NO_PREFIX ?=

.PHONY: up
up: $(LOCAL_ENV_FILE)
	@echo "\033[34m""building, creating and starting containers...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose up -d $(SERVICE)

.PHONY: down
down: $(LOCAL_ENV_FILE)
	@echo "\033[34m""stopping and removing containers and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down $(SERVICE)

.PHONY: clean
clean: $(LOCAL_ENV_FILE)
	@echo "\033[34m""stopping and removing containers, associated volumes and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down -v $(SERVICE)

.PHONY: refresh
refresh: down clean-image up

.PHONY: ps start stop config
ps start stop config: $(LOCAL_ENV_FILE)
	@echo "\033[34m""$@ containers...\033[0m" >&2
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose $@ $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: images
images:
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker $@ $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: image-id
image-id: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker images --format='{{ .ID }} {{ .Repository }}' | awk '/$(SERVICE)$$/{print $$1}'

.PHONY: clean-image
clean-image:
	@i_id=$$(make image-id);								\
		if [[ -z $$i_id ]]; then echo Could not get image-id >&2; exit 3; fi;		\
		if [[ $$i_id =~ [[:space:]] && -z "$(MULTI_OK)" ]]; then echo Use more specific SERVICE, got IDs $$i_id >&2; exit 4; fi;	\
		echo "\033[34m""Removing image '$$i_id' for $(SERVICE)\033[0m" >&2;		\
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker image rm $$i_id

.PHONY: countainer-id
countainer-id: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker ps --format='{{ .ID }} {{ .Names }}' | awk '/$(SERVICE)/{print $$1}'

.PHONY: attach
attach: $(LOCAL_ENV_FILE)
	@c_id=$$(make countainer-id);								\
		if [[ -z $$c_id ]]; then echo Could not get container-id >&2; exit 3; fi;	\
		if [[ $$c_id =~ [[:space:]] && -z "$(MULTI_OK)" ]]; then echo Use more specific SERVICE, got IDs $$c_id >&2; exit 4; fi;	\
		echo "\033[34m""Attaching to container '$$c_id' for $(SERVICE)\033[0m" >&2;			\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker exec -it $$c_id bash

.PHONY: logs logs-tail
logs logs-tail: $(LOCAL_ENV_FILE)
	@logs_arg="";	\
		[[ $@ == logs-tail ]]		&& logs_arg+="-f ";	\
		[[ -n "$(LOGS_TIMESTAMP)" ]]	&& logs_arg+="-t ";	\
		[[ -n "$(LOGS_NO_PREFIX)" ]]	&& logs_arg+="--no-log-prefix ";	\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose logs $$logs_arg $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: health
health: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) $(SCRIPTS_DIR)/health.sh

.PHONY: base-init
base-init: clone $(LOCAL_ENV_FILE)

.PHONY: clone
clone:
	@$(SCRIPTS_DIR)/clone.sh

.PHONY: pull git-status
pull git-status:
	@$(SCRIPTS_DIR)/clone.sh $@

.PHONY: list-apps
list-apps:
	@make config | yq -r '.services | to_entries | .[] | select(.value | has("x-repo-url")) | .key'

.PHONY: list-repos
list-repos:
	@make config | yq -r '.services | to_entries | .[].value."x-repo-url" | select(.)' | sort

.PHONY: list-services
list-services:
	@make config | yq -r '.services | keys | .[]'

.PHONY: list-environment
list-env-vars:
	@make config | yq '.services.[].environment | select(.) | keys | .[]' | sort -u

$(LOCAL_ENV_FILE): |../$(LOCAL_ENV_FILE).tmpl
	cp ../$(LOCAL_ENV_FILE).tmpl $(LOCAL_ENV_FILE)

.PHONY: check-sanity
check-sanity: check-versions check-env-vars

.PHONY: check-versions
check-versions:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		is_version java			"$$(java -version		2>&1 | sed -En 's/.* version "(.*)"$$/\1/p')"			"1.8.*";	\
		is_version maven		"$$(mvn --version		2>&1 | sed -En 's/.* Maven ([0-9]+\..*) .*/\1/p')"		"3.*";		\
		is_version docker		"$$(docker --version		2>&1 | sed -En 's/.* version ([^ ]+) .*/\1/p')"			"25.*";		\
		is_version docker-compose	"$$(docker-compose --version	2>&1 | sed -En 's/.* version v([0-9.]+.*)/\1/p')"		"2.2?.*"

.PHONY: check-env-vars
check-env-vars:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		for env_var in $$(make list-env-vars); do				\
			[[ "$$env_var" == *.* ]] && continue;				\
			eval val=\$${$$env_var-DoesNotExist};				\
			[[ "$$val" == "DoesNotExist" ]] && continue;			\
			warning "env var is from your environment: $$env_var";		\
		done
