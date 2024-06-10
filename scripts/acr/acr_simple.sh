#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acrrg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr0"$RANDOM_SUFFIX

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az acr create \
--name ${ACR_REGISTRY_NAME} \
-g ${RESOURCE_GROUP} \
--sku Basic

az acr login --name ${ACR_REGISTRY_NAME}

docker pull alpine:latest
docker tag alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
docker push ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
docker rmi alpine:latest
docker rmi ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
docker image ls
docker pull ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
docker run -i ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
