#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acr_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr"$RANDOM_SUFFIX

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az acr create \
--name $ACR_REGISTRY_NAME \
--resource-group $RESOURCE_GROUP \
--sku Basic

# login to acr
az acr login \
--name $ACR_REGISTRY_NAME

# The following example pulls the hello-world image from a public Microsoft Container Registry to your local computer
# or use your own local image
docker pull mcr.microsoft.com/hello-world

# Before you can push an image to your registry, you must tag it with the fully qualified name of your registry login server. 
# The login server name is in the format <registry-name>.azurecr.io (must be all lowercase), 
# for example, mycontainerregistryapl2003.azurecr.io.
docker tag mcr.microsoft.com/hello-world $ACR_REGISTRY_NAME.azurecr.io/hello-world:1.0

# push image to ACR
docker push $ACR_REGISTRY_NAME.azurecr.io/hello-world:1.0

az acr repository list --name $ACR_REGISTRY_NAME

# delete local image if needed
docker rmi $ACR_REGISTRY_NAME.azurecr.io/hello-world:1.0

# pull from ACR to local
docker pull $ACR_REGISTRY_NAME.azurecr.io/hello-world:1.0

# run
docker run $ACR_REGISTRY_NAME.azurecr.io/hello-world:1.0

echo "Show usage ${ACR_REGISTRY_NAME}"
az acr show-usage --name $ACR_REGISTRY_NAME -g $RESOURCE_GROUP

echo "Press any key to delete resource group $RESOURCE_GROUP ..."
read -s -n 1

echo "Sleep"
sleep 1

echo "Delete resource group ${RESOURCE_GROUP}"
az group delete --name $RESOURCE_GROUP --no-wait --yes
az group list -o table


