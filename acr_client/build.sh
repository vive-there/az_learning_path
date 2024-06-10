#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acrrg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr0"$RANDOM_SUFFIX

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic

az acr build \
--registry ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image mytest:1.0 \
--file ${HOME}/azure/repos/acr-build-helloworld-node/Dockerfile \
${HOME}/azure/repos/acr-build-helloworld-node/.

az acr login --name ${ACR_REGISTRY_NAME}

docker pull alpine:latest
docker tag alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/myalpine:0.1
docker push ${ACR_REGISTRY_NAME}.azurecr.io/myalpine:0.1
docker rmi alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/myalpine:0.1 --force

#dotnet new create console <project name>
#dotnet new gitignore
#dotnet add package Azure.Containers.ContainerRegistry --prerelease

dotnet build acr_client.csproj -c Release -r linux-x64 --self-contained true
chmod u+x ${HOME}/azure/repos/az_learning_path/acr_client/bin/Release/net8.0/linux-x64/acr_client
${HOME}/azure/repos/az_learning_path/acr_client/bin/Release/net8.0/linux-x64/acr_client "https://${ACR_REGISTRY_NAME}.azurecr.io"
