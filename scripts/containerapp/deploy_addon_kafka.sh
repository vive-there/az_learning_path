#!/bin/bash
RESOURCE_GROUP="kafka-dev1"
LOCATION="northcentralus"
ENVIRONMENT="aca-env1"
KAFKA_SVC="kafka01"
KAFKA_CLI_APP="kafka-cli-app"
KAFKA_UI_APP="kafka-ui-app"

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location $LOCATION

ENVIRONMENT_ID=$(echo $(az containerapp env show --name $ENVIRONMENT --resource-group $RESOURCE_GROUP --query id --output tsv) | tr -d '\n\t\r ')
echo $ENVIRONMENT_ID

az containerapp add-on kafka create \
--name $KAFKA_SVC \
--resource-group $RESOURCE_GROUP \
--environment $ENVIRONMENT

# az containerapp logs show \
# --name $KAFKA_SVC \
# --resource-group $RESOURCE_GROUP \
# --follow \
# --tail 30

az containerapp create \
--name "$KAFKA_CLI_APP" \
--image mcr.microsoft.com/k8se/services/kafka:3.4 \
--bind "$KAFKA_SVC" \
--environment "$ENVIRONMENT" \
--resource-group "$RESOURCE_GROUP" \
--min-replicas 1 \
--max-replicas 1 \
--command "/bin/sleep" 
--args infinity

az containerapp exec \
--name "$KAFKA_CLI_APP" \
--resource-group "$RESOURCE_GROUP" \
--command /bin/bash
