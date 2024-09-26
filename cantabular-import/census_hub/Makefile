SERVICE_DIR=services
DP_DESIGN_SYSTEM_PATH=./services/dp-design-system
DP_FRONTEND_HOMEPAGE_CONTROLLER_PATH=./services/dp-frontend-homepage-controller
DP_FRONTEND_ROUTER_PATH=./services/dp-frontend-router
DP_API_ROUTER_PATH=./services/dp-api-router
DP_TOPICS_API_PATH=./services/dp-topic-api
DP_SIXTEENS_PATH=./services/sixteens
ZEBEDEE_PATH=./services/zebedee

clone:
	$(RM) -rf $(SERVICE_DIR)
	mkdir $(SERVICE_DIR)
	git clone git@github.com:ONSdigital/dp-design-system.git $(SERVICE_DIR)/dp-design-system
	git clone git@github.com:ONSdigital/dp-frontend-homepage-controller.git $(SERVICE_DIR)/dp-frontend-homepage-controller
	git clone git@github.com:ONSdigital/dp-frontend-router.git $(SERVICE_DIR)/dp-frontend-router
	git clone git@github.com:ONSdigital/dp-api-router.git $(SERVICE_DIR)/dp-api-router
	git clone git@github.com:ONSdigital/dp-topic-api.git $(SERVICE_DIR)/dp-topic-api
	git clone git@github.com:ONSdigital/sixteens.git $(SERVICE_DIR)/sixteens
	git clone git@github.com:ONSdigital/zebedee.git $(SERVICE_DIR)/zebedee


up-build:
	DP_DESIGN_SYSTEM_PATH=$(DP_DESIGN_SYSTEM_PATH) \
	DP_FRONTEND_HOMEPAGE_CONTROLLER_PATH=$(DP_FRONTEND_HOMEPAGE_CONTROLLER_PATH) \
	DP_FRONTEND_ROUTER_PATH=$(DP_FRONTEND_ROUTER_PATH) \
	DP_API_ROUTER_PATH=$(DP_API_ROUTER_PATH) \
	DP_TOPICS_API_PATH=$(DP_TOPICS_API_PATH) \
	DP_SIXTEENS_PATH=$(DP_SIXTEENS_PATH) \
	ZEBEDEE_PATH=$(ZEBEDEE_PATH) \
docker-compose up --build --remove-orphans

up:
	DP_DESIGN_SYSTEM_PATH=$(DP_DESIGN_SYSTEM_PATH) \
	DP_FRONTEND_HOMEPAGE_CONTROLLER_PATH=$(DP_FRONTEND_HOMEPAGE_CONTROLLER_PATH) \
	DP_FRONTEND_ROUTER_PATH=$(DP_FRONTEND_ROUTER_PATH) \
	DP_API_ROUTER_PATH=$(DP_API_ROUTER_PATH) \
	DP_TOPICS_API_PATH=$(DP_TOPICS_API_PATH) \
	DP_SIXTEENS_PATH=$(DP_SIXTEENS_PATH) \
	ZEBEDEE_PATH=$(ZEBEDEE_PATH) \
docker-compose up --remove-orphans


install-up:
	make clone
	make up-build
