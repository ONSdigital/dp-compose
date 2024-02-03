# Specifies the service upon which to act, by default this is all services
SERVICE ?=

.PHONY: up
up:
	@echo "building, creating and starting containers..."
	docker-compose up -d $(SERVICE)

.PHONY: down
down:
	@echo "stopping and removing containers and networks..."
	docker-compose down $(SERVICE)

.PHONY: clean
clean:
	@echo "stopping and removing containers, associated volumes and networks..."
	docker-compose down -v $(SERVICE)

.PHONY: start
start:
	@echo "starting containers..."
	docker-compose start $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: stop
stop:
	@echo "stopping containers..."
	docker-compose stop $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: logs
logs:
	docker-compose logs -f $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: ps
ps:
	docker-compose ps $(SERVICE) $(ENV_FILE_ARGS)

.PHONY: health
health:
	@../../scripts/health.sh

.PHONY: base-init
base-init: clone

.PHONY: clone
clone:
	@../../scripts/clone.sh
