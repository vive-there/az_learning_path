#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacrbuild1"$RANDOM_SUFFIX
DOCKER_NAME=acr-helloworld-web
DOCKER_TAG_VERSION=0.01
DOCKER_IMAGE_WITH_TAG=${DOCKER_NAME}:${DOCKER_TAG_VERSION}

# az login --use-device-code
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic \
--admin-enabled true

az acr login --name ${ACR_REGISTRY_NAME}

pushd ${HOME}/azure/repos/acr-helloworld-web
docker build \
-t ${DOCKER_IMAGE_WITH_TAG} \
-f ./HelloworldWeb/Dockerfile \
--build-arg ACR_NAME=${ACR_REGISTRY_NAME} \
.

docker tag \
${DOCKER_IMAGE_WITH_TAG} \
${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG}

docker push \
${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG}

popd

