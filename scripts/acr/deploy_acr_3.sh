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
USER_ASSIGNED_IDENITY_NAME=uaiuser

# az login --use-device-code

#Create a resource group
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

#Create a managed user identity in the resource group
az identity create \
--name ${USER_ASSIGNED_IDENITY_NAME} \
--resource-group ${RESOURCE_GROUP}

#Get user principal id, id and client id
UAID_PRINCIPAL_ID=$(echo $(az identity show --name ${USER_ASSIGNED_IDENITY_NAME} --resource-group ${RESOURCE_GROUP} --query principalId --output tsv) | tr -d "\r\t\n ")
UAID_ID=$(echo $(az identity show --name ${USER_ASSIGNED_IDENITY_NAME} --resource-group ${RESOURCE_GROUP} --query id --output tsv) | tr -d "\r\t\n ")
UAID_CLIENTID=$(echo $(az identity show --name ${USER_ASSIGNED_IDENITY_NAME} --resource-group ${RESOURCE_GROUP} --query clientId --output tsv) | tr -d "\r\t\n ")

#Create ACR
az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic \
--admin-enabled true

#Get ACR id
ACR_REGISTRY_ID=$(echo $(az acr show --name ${ACR_REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} --query id -o tsv) | tr -d "\t\r\n ")

#Assign a role acrpull to user managed identity principalId and scope ACR id
az role assignment create \
--scope ${ACR_REGISTRY_ID} \
--assignee ${UAID_PRINCIPAL_ID} \
--role acrpull

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

#Create a webapp with ACR container image
az webapp create \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--plan ${APPSERVICE_PLAN_NAME} \
--container-image-name ${ACR_REGISTRY_NAME}.azurecr.io/${DOCKER_IMAGE_WITH_TAG} \
--acr-use-identity

#Container is listening on port 8080 for web requests, and you configure the app to send requests to port 8080.
az webapp config appsettings set \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--settings WEBSITES_PORT=8080

#Use the user managed identity to pull images from your container registry.
az webapp identity assign \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--identities ${UAID_ID}

WEBAPP_CONFIG_ID=$(echo $(az webapp config show --name ${WEBAPP_NAME} --resource-group ${RESOURCE_GROUP} --query id --output tsv) | tr -d "\t\r\n ")
#Configure your app to pull from Azure Container Registry by using managed identities.
#az resource update --ids ${WEBAPP_CONFIG_ID} --set properties.AcrUseManagedIdentityCreds=True
#Set the client ID your web app uses to pull from Azure Container Registry. This step isn't needed if you use the system-assigned managed identity.
az resource update --ids ${WEBAPP_CONFIG_ID} --set properties.AcrUserManagedIdentityID=${UAID_CLIENTID}

az webapp log config \
--name ${WEBAPP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--docker-container-logging filesystem











