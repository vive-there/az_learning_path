#!/bin/bash
RESOURCE_GROUP="postgres-dev"
LOCATION="northcentralus"
ENVIRONMENT="aca-env-psql"
PG_SVC="postgres01"
PSQL_CLI_APP="psql-cloud-cli-app"

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RESOURCE_GROUP \
--location $LOCATION

az containerapp add-on postgres create \
--name "$PG_SVC" \
--resource-group "$RESOURCE_GROUP" \
--environment "$ENVIRONMENT"

#wait for 2 minutes
sleep 120s

#az containerapp logs show \
#--name "$PG_SVC" \
#--resource-group "$RESOURCE_GROUP" \
#--follow \
#--tail 30

az containerapp create \
    --name "$PSQL_CLI_APP" \
    --image mcr.microsoft.com/k8se/services/postgres:14 \
    --bind "$PG_SVC" \
    --environment "$ENVIRONMENT" \
    --resource-group "$RESOURCE_GROUP" \
    --min-replicas 1 \
    --max-replicas 1 \
    --command /bin/sleep infinity

sleep 120s

az containerapp exec \
    --name $PSQL_CLI_APP \
    --resource-group $RESOURCE_GROUP \
    --command /bin/bash