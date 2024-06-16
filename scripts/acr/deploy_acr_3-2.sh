#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacrbuild1"$RANDOM_SUFFIX
DOCKER_NAME=acr-helloworld-web
DOCKER_TAG_VERSION=latest
DOCKER_IMAGE_WITH_TAG=${DOCKER_NAME}:${DOCKER_TAG_VERSION}
APPSERVICE_PLAN_NAME=vtasplan${RANDOM_SUFFIX}
WEBAPP_NAME=acrhelloworld$RANDOM_SUFFIX

# az login --use-device-code

#Create a resource group
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

#Create ACR
az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic \
--admin-enabled true

#Login into ACR
az acr login --name ${ACR_REGISTRY_NAME}

#Change directory
pushd ${HOME}/azure/repos/acr-helloworld-web

#Build docker image from local repository
docker build \
-t ${DOCKER_IMAGE_WITH_TAG} \
-f ./HelloworldWeb/Dockerfile \
--build-arg ACR_NAME=${ACR_REGISTRY_NAME} \
.

#Tag an image
docker tag \
${DOCKER_IMAGE_WITH_TAG} \
${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG}

#Push an image to ACR
docker push \
${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG}

#Change directory
popd

#Create an appservice plan
az appservice plan create \
--name ${APPSERVICE_PLAN_NAME} \
--resource-group ${RESOURCE_GROUP} \
--is-linux \
--sku F1

#Create a webapp + system managed identity with default role Contributor + acr usee identity + ACR container image
az webapp create \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--plan ${APPSERVICE_PLAN_NAME} \
--acr-use-identity \
--assign-identity "[system]" \
--container-image-name ${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG}

#Get ACR id
ACR_REGISTRY_ID=$(echo $(az acr show --name ${ACR_REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} --query id -o tsv) | tr -d "\t\r\n ")

#Assign role acrpull for ACR resource to system managed identity
az webapp identity assign \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--identities "[system]" \
--role acrpull \
--scope ${ACR_REGISTRY_ID} \

#Container is listening on port 8080 for web requests, and we configure the app to send requests to port 8080.
az webapp config appsettings set \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--settings WEBSITES_PORT=8080

az webapp log config \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--docker-container-logging filesystem

#Enable CI/CD in webapp
CI_CD_URL=$(echo $(az webapp deployment container config --name ${WEBAPP_NAME} --resource-group ${RESOURCE_GROUP} --enable-cd true --query CI_CD_URL -o tsv) | tr -d "\t\r\n ")

#Create webhook in ACR
WEBHOOK_NAME=webhookacrhelloworld$RANDOM_SUFFIX
az acr webhook create \
--resource-group ${RESOURCE_GROUP} \
--name ${WEBHOOK_NAME} \
--registry ${ACR_REGISTRY_NAME} \
--actions push \
--uri ${CI_CD_URL} \
--scope ${DOCKER_IMAGE_WITH_TAG}

#test webhook
eventId=$(echo $(az acr webhook ping --name ${WEBHOOK_NAME} --registry ${ACR_REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} --query id --output tsv) | tr -d "\t\r\n ")
az acr webhook list-events --name ${WEBHOOK_NAME} --registry ${ACR_REGISTRY_NAME} --resource-group ${RESOURCE_GROUP}  --query "[?id=='$eventId'].eventResponseMessage"








