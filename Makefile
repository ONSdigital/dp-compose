.PHONY: deprecated
deprecated:
	@echo "\033[33m""⚠️ DEPRECATED ⚠️: This stack is deprecated and will be removed soon. Please see README.md#upgrading-to-v2 to upgrade now.\033[0m"

.PHONY: start
start: deprecated
	@echo "starting dp-compose containers"
	docker-compose up

.PHONY: start-detached
start-detached: deprecated
	@echo "starting dp-compose containers in background"
	docker-compose up -d

.PHONY: stop
stop: deprecated
	@echo "stopping dp-compose containers"
	docker-compose stop

.PHONY: down
down: deprecated
	@echo "stopping and removing dp-compose containers and networks"
	docker-compose down

.PHONY: clean
clean: deprecated
	@echo "stopping and removing dp-compose containers, associated volumes and networks"
	docker-compose down -v

.PHONY: restart
restart: deprecated
	@echo "restarting dp-compose containers"
	docker-compose restart
