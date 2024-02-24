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
ENABLE_MULTI ?=

LOGS_TIMESTAMP ?=
LOGS_NO_PREFIX ?=
QUIET ?=

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
	@[[ -n "$(QUIET)" ]] || echo "\033[34m""$@ containers...\033[0m" >&2
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
		if [[ -z $$i_id ]]; then echo "Could not get image-id" >&2; exit 3; fi;		\
		if [[ $$i_id =~ [[:space:]] && -z "$(ENABLE_MULTI)" ]]; then echo "Use more specific SERVICE or ENABLE_MULTI=1, got >1 IDs $$i_id" >&2; exit 4; fi;	\
		echo "\033[34m""Removing image '$$i_id' for $(SERVICE)\033[0m" >&2;		\
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker image rm $$i_id

.PHONY: countainer-id
countainer-id: $(LOCAL_ENV_FILE)
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker ps --format='{{ .ID }} {{ .Names }}' | awk '/$(SERVICE)/{print $$1}'

.PHONY: attach
attach: $(LOCAL_ENV_FILE)
	@c_id=$$(make countainer-id);								\
		if [[ -z $$c_id ]]; then echo "Could not get container-id" >&2; exit 3; fi;	\
		if [[ $$c_id =~ [[:space:]] ]]; then echo "Use more specific SERVICE or ENABLE_MULTI=1, got IDs $$c_id" >&2; exit 4; fi;	\
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

.PHONY: clone pull git-status
clone pull git-status:
	@$(SCRIPTS_DIR)/clone.sh $@

.PHONY: list-apps
list-apps:
	@make QUIET=1 config | yq -r '.services | to_entries | .[] | select(.value | has("x-repo-url")) | .key'

.PHONY: list-repos
list-repos:
	@make QUIET=1 config | yq -r '.services | to_entries | .[].value."x-repo-url" | select(.)' | sort

.PHONY: list-services
list-services:
	@make QUIET=1 config | yq -r '.services | keys | .[]'

.PHONY: list-environment
list-env-vars:
	@make QUIET=1 config | yq '.services.[].environment | select(.) | keys | .[]' | sort -u

$(LOCAL_ENV_FILE): |../$(LOCAL_ENV_FILE).tmpl
	cp ../$(LOCAL_ENV_FILE).tmpl $(LOCAL_ENV_FILE)

.PHONY: check
check: check-config check-versions check-env-vars

check-config:
	@source $(SCRIPTS_DIR)/utils.sh;		\
		cfg="$$(make config QUIET=1)";		\
		for app in $$(make list-apps); do	\
			test0=$$(yq '.services["'"$$app"'"].healthcheck.test[0]' <<<"$$cfg");	\
			[[ $$test0 != null ]] || warning "$$(colour $$BOLD $$app) has no healthcheck";		\
		done

.PHONY: check-versions
check-versions:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		is_ver java		"$$(java -version		2>&1 | sed -En 's/.* version "(.*)"$$/\1/p')"		"1\.8\.*";		\
		is_ver maven		"$$(mvn --version		2>&1 | sed -En 's/.* Maven ([0-9]+\..*) .*/\1/p')"	"3\.*";			\
		is_ver docker		"$$(docker --version		2>&1 | sed -En 's/.* version ([^ ]+), .*/\1/p')"		"25\.*";		\
		is_ver docker-compose	"$$(docker-compose --version	2>&1 | sed -En 's/.* version v?([0-9.]+.*)/\1/p')"	"2\.2?\.*";		\
		: is_ver nvm		"$$(nvm --version		2>&1 )"							"0\.[3-9][0-9]\..*";	\
		: is_ver npm		"$$(npm --version		2>&1 )"							"0\.[3-9][0-9]\..*"

.PHONY: check-env-vars
check-env-vars:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		for env_var in $$(make list-env-vars); do				\
			[[ "$$env_var" == *.* ]] && continue;				\
			eval val=\$${$$env_var-DoesNotExist};				\
			[[ "$$val" == "DoesNotExist" ]] && continue;			\
			warning "env var is from your environment: $$(colour $$BOLD $$env_var)";	\
		done
