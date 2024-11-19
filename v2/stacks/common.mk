# Specifies the service upon which to act, by default this is all services
SERVICE ?=

# Specifies the default environment variable file for the stack
DEFAULT_ENV_FILE ?= default.env

# Specifies the local override environment variable file for the stack
LOCAL_ENV_FILE ?= local.env

# Specifies the environment variables files for docker compose to use.
# See the docs for more details:
# https://docs.docker.com/compose/environment-variables/envvars/#compose_env_files
COMPOSE_ENV_FILES ?= $(DEFAULT_ENV_FILE),$(LOCAL_ENV_FILE)

SCRIPTS_DIR ?= ../../scripts

# by default, do not act on more than one (app, image, etc)
ENABLE_MULTI ?=

LOGS_TIMESTAMP ?=
LOGS_NO_PREFIX ?=
LOGS_TAIL ?=
QUIET ?=

# colima start args specifying the default resource allocations
COLIMA_START_ARGS ?= --cpu 4 --memory 8 --disk 100

# crude check to see if SERVICE is set and correct (needs to avoid recursion, hence using the yml files)
.PHONY: verify-service
verify-service: $(LOCAL_ENV_FILE)
	@[[ -z "$(SERVICE)" ]] && exit 0;							\
	for compose_env_f in $(shell sed 's/,/ /g' <<<"$(COMPOSE_ENV_FILES)"); do		\
		source $$compose_env_f;								\
	done;											\
	for compose_f in $$(sed 's/:/ /g' <<<"$$COMPOSE_FILE"); do				\
		for svc in $$(yq -r '.services | keys | .[]' $$compose_f); do			\
			[[ "$(SERVICE)" = $$svc ]] && exit 0;					\
		done;										\
	done;											\
	exit 4

.PHONY: colima-start
colima-start:
	@( docker ps > /dev/null 2>&1 ) || ( echo "\033[34m""starting colima...\033[0m" && colima start $(COLIMA_START_ARGS) )

.PHONY: up
up: init verify-service colima-start
	@echo "\033[34m""building, creating and starting containers...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose up -d $(SERVICE)

.PHONY: down
down: verify-service colima-start
	@echo "\033[34m""stopping and removing containers and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down $(SERVICE)

.PHONY: clean
clean: verify-service colima-start
	@echo "\033[34m""stopping and removing containers, associated volumes and networks...\033[0m"
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose down -v $(SERVICE)

.PHONY: refresh
refresh: down clean-image up

.PHONY: ps start stop config
ps start stop config: verify-service colima-start
	@[[ -n "$(QUIET)" ]] || echo "\033[34m""$@ containers...\033[0m" >&2
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose $@ $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: images
images: verify-service colima-start
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker $@ $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: ps-docker
ps-docker: verify-service colima-start
	@do=$@; do=$${do%-docker};	\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker $$do $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: get-repository-name
get-repository-name: verify-service
	@if [[ -n "$(SERVICE)" ]]; then						\
		APPS="$(shell make list-apps)";					\
		if [[ " $${APPS[*]} " == *" $(SERVICE) "* ]]; then		\
			echo $(shell make config | yq .name)-$(SERVICE);	\
		else								\
			echo $(SERVICE);					\
		fi;								\
	fi

.PHONY: image-id
image-id: $(LOCAL_ENV_FILE) colima-start
	@REPO_NAME=$(shell make get-repository-name);		\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker images --format='{{ .ID }} {{ .Repository }}' | awk '$$2~/'"$$REPO_NAME"'$$/{print $$1}'

.PHONY: clean-image
clean-image: verify-service colima-start
	@i_id=$$(make image-id);								\
		if [[ -z $$i_id ]]; then echo "Could not get image-id" >&2; exit 3; fi;		\
		if [[ $$i_id =~ [[:space:]] && -z "$(ENABLE_MULTI)" ]]; then echo "Use more specific SERVICE or ENABLE_MULTI=1, got >1 IDs $$i_id" >&2; exit 4; fi;	\
		echo "\033[34m""Removing image '$$i_id' for $(SERVICE)\033[0m" >&2;		\
	COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker image rm $$i_id

.PHONY: container-id
container-id: verify-service colima-start
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker ps --format='{{ .ID }} {{ .Names }}' | awk '/$(SERVICE)/{print $$1}'

.PHONY: attach
attach: verify-service colima-start
	@c_id=$$(make container-id);								\
		if [[ -z $$c_id ]]; then echo "Could not get container-id" >&2; exit 3; fi;	\
		if [[ $$c_id =~ [[:space:]] ]]; then echo "Use more specific SERVICE or ENABLE_MULTI=1, got IDs $$c_id" >&2; exit 4; fi;	\
		echo "\033[34m""Attaching to container '$$c_id' for $(SERVICE)\033[0m" >&2;			\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker exec -it $$c_id bash

.PHONY: logs
logs: verify-service colima-start
	@logs_arg="";	\
		[[ -n "$(LOGS_TAIL)" ]]		&& logs_arg+="-f ";	\
		[[ -n "$(LOGS_TIMESTAMP)" ]]	&& logs_arg+="-t ";	\
		[[ -n "$(LOGS_NO_PREFIX)" ]]	&& logs_arg+="--no-log-prefix ";	\
		COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) docker-compose logs $$logs_arg $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: health
health: $(LOCAL_ENV_FILE) colima-start
	@COMPOSE_ENV_FILES=$(COMPOSE_ENV_FILES) $(SCRIPTS_DIR)/health.sh

.PHONY: base-init
base-init: clone $(LOCAL_ENV_FILE)

.PHONY: clone pull git-status check-repos prep
clone pull git-status check-repos prep:
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
check: check-config check-versions check-env-vars check-repos

.PHONY: check-config
check-config: $(LOCAL_ENV_FILE)
	@source $(SCRIPTS_DIR)/utils.sh;		\
		cfg="$$(make config QUIET=1)";		\
		for app in $$(make list-apps); do	\
			test0=$$(yq '.services["'"$$app"'"].healthcheck.test[0]' <<<"$$cfg");			\
			[[ $$test0 == null ]] || continue;							\
			known=; [[ $$app == the-train ]] && known=" $$(colour $$GREEN "(known issue)")";	\
			warning "$$(colour $$BOLD $$app) has no healthcheck$$known";				\
		done;					\
		res=0; grep -E '^(COMPOSE_|PATH_(MANIFESTS|PROVISIONING))' "$(LOCAL_ENV_FILE)" || res=$$?;				\
			[[ $$res == 1 ]] || warning "Found the above lines in '$(LOCAL_ENV_FILE)' file, when they should not be there (probably)";	\
		test \! -f ".env" || warning "Found '.env' file, but this is no longer used"

.PHONY: check-versions
check-versions:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		is_ver java		"$$(java -version		2>&1 | sed -En 's/.* version "(.*)"$$/\1/p')"		"1\.8\.*";		\
		is_ver maven		"$$(mvn --version		2>&1 | sed -En 's/.* Maven ([0-9]+\..*) .*/\1/p')"	"3\.*";			\
		is_ver docker		"$$(docker --version		2>&1 | sed -En 's/.* version ([^ ]+), .*/\1/p')"	"2[5-9]\.*";		\
		is_ver docker-compose	"$$(docker-compose --version	2>&1 | sed -En 's/.* version v?([0-9.]+.*)/\1/p')"	"2\.2[5-9]\.*";		\
		is_ver yq		"$$(yq --version		2>&1 | sed -En 's/.* version v?([0-9.]+.*)/\1/p')"	"4\.[4-9][0-9].*";	\
		: is_ver nvm		"$$(nvm --version		2>&1 )"							"0\.[3-9][0-9]\..*";	\
		: is_ver npm		"$$(npm --version		2>&1 )"							"0\.[3-9][0-9]\..*"

.PHONY: check-env-vars
check-env-vars:
	@source $(SCRIPTS_DIR)/utils.sh;	\
		for env_var in $$(make list-env-vars); do				\
			[[ "$$env_var" == *.* ]] && continue;				\
			eval val=\$${$$env_var-DoesNotExist};				\
			[[ "$$val" == "DoesNotExist" ]] && continue;			\
			known=; [[ :zebedee_root:AWS_PROFILE:AWS_ACCESS_KEY_ID:AWS_SECRET_ACCESS_KEY:AWS_SESSION_TOKEN: == *:$$env_var:*	\
					|| $$env_var == AWS_COGNITO_* ]] && known="	$$(colour $$GREEN "(expected var)")";			\
			warning "env var is from your environment: $$(colour $$BOLD $$env_var)$$known";	\
		done
