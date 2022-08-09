#!/bin/sh
echo "installing yq"
apt-get update
apt-get install -y wget
VERSION=v4.26.1
BINARY=yq_linux_386
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq \
    && chmod +x /usr/bin/yq


CONFIG_FILE='/dp-configuration.yaml'

configure_service()
{
  KEY=$1

  ORIGIN=/services/${KEY}.yaml
  SWAGGER_FILE=/usr/share/nginx/html/${KEY}.yaml
  cp ${ORIGIN} ${SWAGGER_FILE}

  # Get new config
  SERVERS=$(yq ".services.$KEY.servers" ${CONFIG_FILE})
  OPENAPI=$(yq ".services.$KEY.openapi" ${CONFIG_FILE})

  # Remove config variables
  yq -i 'del(.swagger)' ${SWAGGER_FILE}
  yq -i 'del(.openapi)' ${SWAGGER_FILE}
  yq -i 'del(.basePath)' ${SWAGGER_FILE}
  yq -i 'del(.servers)' ${SWAGGER_FILE}

  # Add OpenApi 3.* config
  yq -i ".openapi = \"$OPENAPI\"" ${SWAGGER_FILE}
  yq -i ".servers = \"$SERVERS"\" ${SWAGGER_FILE}
  sed -i 's/servers: |-/servers:/g' ${SWAGGER_FILE}

  yq -i ".components.securitySchemes.Authorization.type = \"apiKey\"" ${SWAGGER_FILE}
  yq -i ".components.securitySchemes.Authorization.description = \"Service Auth Token\"" ${SWAGGER_FILE}
  yq -i ".components.securitySchemes.Authorization.name = \"Authorization\"" ${SWAGGER_FILE}
  yq -i ".components.securitySchemes.Authorization.in = \"header\"" ${SWAGGER_FILE}
  yq -i ".security.Authorization = []" ${SWAGGER_FILE}
  echo "- CONFIGURED ${KEY}"
}

echo "----------------------------"

echo "CONFIGURING SERVICES"
for SERVICE_FILE in $(ls /services/*.yaml)
do
  configure_service $(basename $SERVICE_FILE .yaml)
done

echo "----------------------------"
