#!/bin/bash
# Build and deploy from a repository to Azure Container Apps
SUFFIX=$RANDOM
RESOURCE_GROUP=learning$SUFFIX
LOCATION=eastus
CONTAINERAPP_ENVIRONMENT=env-vt-$SUFFIX
CONTAINERAPP_NAME=ca-vt-$SUFFIX
CONTAINERAPP_NAME_HELLOWORLD=helloworld-vt-$SUFFIX

echo "Creating resource group ${RESOURCE_GROUP}"
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

echo "Creating container application environment ${CONTAINERAPP_ENVIRONMENT}"
az containerapp env create \
--name ${CONTAINERAPP_ENVIRONMENT} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION}

echo "Creating container application ${CONTAINERAPP_NAME} from image"
az containerapp up \
--name ${CONTAINERAPP_NAME} \
--environment ${CONTAINERAPP_ENVIRONMENT} \
--resource-group ${RESOURCE_GROUP} \
--image mcr.microsoft.com/k8se/quickstart:latest \
--ingress external \
--target-port 80 \
--query properties.configuration.ingress.fqdn

echo "Creating container application ${CONTAINERAPP_NAME_HELLOWORLD} from local source"
az containerapp up \
--name ${CONTAINERAPP_NAME_HELLOWORLD} \
--resource-group ${RESOURCE_GROUP} \
--environment ${CONTAINERAPP_ENVIRONMENT} \
--source "${HOME}/azure/repos/acr-build-helloworld-node/." \
--ingress external \
--target-port 80 \
--query properties.configuration.ingress.fqdn

echo "Resource group ${RESOURCE_GROUP}"
echo "Container application environment ${CONTAINERAPP_ENVIRONMENT}"
echo "Container application name ${CONTAINERAPP_NAME}"