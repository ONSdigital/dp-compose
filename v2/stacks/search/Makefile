.PHONY: start
start:
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

.PHONY: install
install:
	./install.sh

.PHONY: health
health:
	@../../scripts/health.sh

.PHONY: clone
clone:
	@../../scripts/clone.sh
