#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr"$RANDOM_SUFFIX

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--sku Basic \
--admin-enabled true

az acr login --name ${ACR_REGISTRY_NAME}
#or
#docker login ${ACR_REGISTRY_NAME}.azurecr.io

# local
docker pull nginx:latest
# list images
docker image ls
# run local and remove after
docker run -it --rm -p 8080:80 nginx:latest
# tag
docker tag nginx:latest ${ACR_REGISTRY_NAME}.azurecr.io/samples/nginx:latest
# push to acr
docker push ${ACR_REGISTRY_NAME}.azurecr.io/samples/nginx:latest
# pull from acr
docker pull ${ACR_REGISTRY_NAME}.azurecr.io/samples/nginx:latest
# list images
docker image ls
# run
docker run -it --rm -p 8082:80 ${ACR_REGISTRY_NAME}.azurecr.io/samples/nginx:latest
# remove nginx image
docker rmi ${ACR_REGISTRY_NAME}.azurecr.io/samples/nginx:latest --force
docker rmi nginx:latest --force
# list images
docker image ls

# deelte group
az group delete --name ${RESOURCE_GROUP} --no-wait


