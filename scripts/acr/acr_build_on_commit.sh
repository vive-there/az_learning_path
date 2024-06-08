#!/bin/bash
# Build from source context
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acrbuild_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacrbuild1"$RANDOM_SUFFIX
GIT_USER=$1
GIT_PAT=$2

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az acr create \
--name $ACR_REGISTRY_NAME \
--resource-group $RESOURCE_GROUP \
--sku Basic

az acr task create \
--resource-group $RESOURCE_GROUP \
--registry $ACR_REGISTRY_NAME \
--name helloworldtask \
--image helloworld:{{.Run.ID}} \
--file Dockerfile \
--context https://github.com/${GIT_USER}/acr-build-helloworld-node#master \
--git-access-token ${GIT_PAT}

#az acr task list --registry {ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} -o table
#az acr task run --name helloworldtask --registry {ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} -o table
#az acr task listruns --registry {ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} -o table

echo "RESOURCE GROUP  ${RESOURCE_GROUP}"
echo "ACR REGISTRY NAME ${ACR_REGISTRY_NAME}"