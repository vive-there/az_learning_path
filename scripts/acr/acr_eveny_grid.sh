#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr-rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr0"$RANDOM_SUFFIX
SITE_NAME=egviewer${RANDOM_SUFFIX}

az provider register --namespace Microsoft.EventGrid
az provider show --namespace Microsoft.EventGrid --query "registrationState"

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az deployment group create \
--resource-group ${RESOURCE_GROUP} \
--template-uri "https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/master/azuredeploy.json" \
--parameters siteName=$SITE_NAME hostingPlanName=$SITE_NAME-plan

echo "Open https://${SITE_NAME}.azurewebsites.net and then press any key ..."
read -n 1

az acr create \
--name ${ACR_REGISTRY_NAME} \
-g ${RESOURCE_GROUP} \
--sku Basic

ACR_REGISTRY_ID=$(echo $(az acr show --name ${ACR_REGISTRY_NAME} -g ${RESOURCE_GROUP} --query id -o tsv) | tr -d '\t\r\n ')
APP_ENDPOINT=https://${SITE_NAME}.azurewebsites.net/api/updates

az eventgrid event-subscription create \
--name event-sub-acr \
--source-resource-id $ACR_REGISTRY_ID \
--endpoint $APP_ENDPOINT

az acr build \
-g ${RESOURCE_GROUP} \
--registry ${ACR_REGISTRY_NAME} \
--image vtdemo${RANDOM_SUFFIX}:0.1 \
--file Dockerfile \
https://github.com/Azure-Samples/acr-build-helloworld-node.git#main


az acr repository show-tags \
--name ${ACR_REGISTRY_NAME} \
--repository vtdemo${RANDOM_SUFFIX}

az acr repository delete \
--name ${ACR_REGISTRY_NAME} \
--repository vtdemo${RANDOM_SUFFIX}

