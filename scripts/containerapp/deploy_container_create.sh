#!/bin/bash
# Build and deploy from a repository to Azure Container Apps
SUFFIX=$RANDOM
RG=learning$SUFFIX
LOCATION=eastus
ENVIRONMENT=env-vt-$SUFFIX
CONTAINERAPP_NAME=ca-vt-$SUFFIX

az group create \
--name $RG \
--location $LOCATION

az containerapp env create \
--name $ENVIRONMENT \
--resource-group $RG \
--location $LOCATION

az containerapp create \
--name $CONTAINERAPP_NAME \
--resource-group $RG \
--environment $ENVIRONMENT \
--image mcr.microsoft.com/k8se/quickstart:latest \
--target-port 80 \
--ingress 'external' \
--query properties.configuration.ingress.fqdn





