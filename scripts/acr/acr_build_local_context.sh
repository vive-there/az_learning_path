#!/bin/bash
# Build from source context
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus2"
ACR_REGISTRY_NAME="vivethereacr"$RANDOM_SUFFIX
APP_NAME=vthelloacrtasks
APP_VER=1.0

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic \
--admin-enabled true

az acr identity assign \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--identities '[system]'

az acr build \
--registry ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image ${APP_NAME}:${APP_VER} \
--file ${HOME}/azure/repos/acr-build-helloworld-node/Dockerfile \
${HOME}/azure/repos/acr-build-helloworld-node/.

az acr show --name ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP}
az acr show-usage --name ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP}

#az acr run --registry ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} --cmd "$Registry/${APP_NAME}:${APP_VER}" /dev/null


