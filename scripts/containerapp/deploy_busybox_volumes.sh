#! /bin/bash
SUFFIX=$RANDOM
RG=cap$SUFFIX
LOCATION=eastus
ENVIRONMENT=vtcapenv$SUFFIX
APP_NAME=cont$SUFFIX

az group create \
--name $RG \
--location $LOCATION

az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RG \
--location $LOCATION

az containerapp create \
--name $APP_NAME \
--environment $ENVIRONMENT \
--resource-group $RG \
--image busybox:latest \
--min-replicas 1 \
--max-replicas 1 \
--memory 1Gi \
--cpu 0.5 \
--command /bin/sleep \
--args infinity

# az containerapp show \
# --name $APP_NAME \
# --resource-group $RG \
# -o yaml \
# > bb.yaml

#az containerapp update --name cont31752 -g cap31752 --yaml ./bb1.yaml
#az containerapp exec --name cont31752 -g cap31752 --command /bin/sh


