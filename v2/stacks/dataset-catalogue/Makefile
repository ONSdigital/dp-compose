# Include common make targets
include ../common.mk

.PHONY: init
init: base-init
	# Add stack specific initialisation logic here

# Add any stack specific helper targets here

.PHONY: seed-topic-api
seed-topic-api:
	@echo "Seeding topic API database..."
	@if [ -d "$$HOME/src/github.com/ONSdigital/dp-topic-api" ]; then \
		echo "Found dp-topic-api at $$HOME/src/github.com/ONSdigital/dp-topic-api"; \
		cd "$$HOME/src/github.com/ONSdigital/dp-topic-api" && make database-seed; \
	else \
		echo "dp-topic-api not found at $$HOME/src/github.com/ONSdigital/dp-topic-api"; \
		echo "Please provide the path to the dp-topic-api directory on your system:"; \
		read -p "Path to dp-topic-api: " custom_path; \
		if [ -d "$$custom_path" ]; then \
			cd "$$custom_path" && make database-seed; \
		else \
			echo "Invalid path. Please ensure dp-topic-api is cloned somewhere on your system."; \
			exit 1; \
		fi; \
	fi

.PHONY: up-with-seed
up-with-seed:
	$(MAKE) up
	$(MAKE) seed-topic-api