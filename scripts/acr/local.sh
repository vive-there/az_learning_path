#!/bin/bash
# declare the variables
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus2"
ACR_REGISTRY_NAME="vivethereacr"$RANDOM_SUFFIX
GIT_USER=$1

echo "Create a resource group ${RESOURCE_GROUP}"
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

echo "Creata an ACR ${ACR_REGISTRY_NAME}"
az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--sku Basic

ACR_LOGIN_SERVER=$(echo  $(az acr show-endpoints --name ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} --query loginServer -o tsv) | tr -d "\n\r\t")
echo ${ACR_LOGIN_SERVER}

echo "Login into ACR ${ACR_REGISTRY_NAME}"
az acr login \
--name ${ACR_REGISTRY_NAME}


echo "Pull docker image mcr.microsoft.com/hello-world"
docker pull mcr.microsoft.com/hello-world

echo "Tag docker image localy"
docker tag mcr.microsoft.com/hello-world ${ACR_LOGIN_SERVER}/hello-world:1.0

echo "Push ${ACR_LOGIN_SERVER}/hello-world:1.0 to ACR"
docker push ${ACR_LOGIN_SERVER}/hello-world:1.0

az acr check-health \
--name ${ACR_REGISTRY_NAME} \
--yes

az acr show \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP}

echo "List repository"
az acr repository list \
--name ${ACR_REGISTRY_NAME}

az acr repository show \
--name ${ACR_REGISTRY_NAME} \
--image hello-world:1.0

az acr show-usage --name ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP}

echo "Test image hello-world:1.0"
az acr run --registry ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} --cmd '$Registry/hello-world:1.0' /dev/null

