.PHONY: start
start:  check-variables
	@echo "starting containers"
	docker-compose up


.PHONY: start-detached
start-detached:
	@echo "starting containers in background"
	docker-compose up -d

.PHONY: stop
stop:
	@echo "stopping containers"
	docker-compose stop

.PHONY: down
down:
	@echo "stopping and removing containers and networks"
	docker-compose down

.PHONY: clean
clean:
	@echo "stopping and removing containers, associated volumes and networks"
	docker-compose down -v

check-variables:
	$(call check_defined, AWS_ACCESS_KEY_ID )
	$(call check_defined, AWS_SECRET_ACCESS_KEY )
	$(call check_defined, AWS_DEFAULT_REGION )
	$(call check_defined, AWS_SESSION_TOKEN )
	$(call check_defined, AWS_COGNITO_USER_POOL_ID )
	$(call check_defined, AWS_COGNITO_CLIENT_ID )
	$(call check_defined, AWS_COGNITO_CLIENT_SECRET )
	$(call check_defined, SERVICE_AUTH_TOKEN )
	$(call check_defined, zebedee_root )

check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
	$(error Undefined environment variable: $1$(if $2, ($2))))

.PHONY: health
health:
	@../../scripts/health.sh
