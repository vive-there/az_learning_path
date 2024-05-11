#!/bin/bash
SUFFIX=$RANDOM
RESOURCE_GROUP="album-containerapps-"$SUFFIX
LOCATION="eastus"
ENVIRONMENT="env-album-containerapps-vt-"$SUFFIX
API_NAME="album-api-"$SUFFIX
FRONTEND_NAME="album-ui-"$SUFFIX
GITHUB_USERNAME="vive-there"

ACR_NAME="acaalbumsvt"$SUFFIX

echo "----> Create resource group $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location "$LOCATION"

echo "----> Create an Azure Container Registry $ACR_NAME"
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

echo "----> Build the container with ACR and push image into ACR repo"
az acr build --registry $ACR_NAME --resource-group $RESOURCE_GROUP --image $API_NAME -f ./code-to-cloud/src/Dockerfile ./code-to-cloud/src/.

echo "----> Create a Container Apps environment $ENVIRONMENT"
az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location $LOCATION

echo "----> Deploy your image $ACR_NAME.azurecr.io/$API_NAME to a container app $API_NAME"
#Check target port in Dockerfile!!! Use target port from EXPOSE in Dockerfile
az containerapp create \
--name $API_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$API_NAME \
--target-port 8080 \
--ingress "external" \
--registry-server $ACR_NAME.azurecr.io \
--query properties.configuration.ingress.fqdn

echo "----> Get API base url"
API_BASE_URL=$(echo $(az containerapp show --resource-group $RESOURCE_GROUP --name $API_NAME --query properties.configuration.ingress.fqdn -o tsv) | tr -d '\n\t\r ')
echo "----> API base url $API_BASE_URL"

echo "----> Build the front end application $FRONTEND_NAME"
az acr build \
--registry $ACR_NAME \
--resource-group $RESOURCE_GROUP \
--image $FRONTEND_NAME \
--file ./code-to-cloud-ui/src/Dockerfile \
./code-to-cloud-ui/src/.

echo "----> Deploy front end application $FRONTEND_NAME image $ACR_NAME.azurecr.io/$FRONTEND_NAME"
az containerapp create \
--name $FRONTEND_NAME \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT \
--image $ACR_NAME.azurecr.io/$FRONTEND_NAME \
--target-port 3000 \
--env-vars API_BASE_URL=https://$API_BASE_URL \
--ingress 'external' \
--registry-server $ACR_NAME.azurecr.io \
--query properties.configuration.ingress.fqdn

echo "Done!!! <--------------------"