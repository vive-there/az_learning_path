#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acrrg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr0"$RANDOM_SUFFIX

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

az acr create \
--name ${ACR_REGISTRY_NAME} \
-g ${RESOURCE_GROUP} \
--sku Basic

az acr login --name ${ACR_REGISTRY_NAME}

docker pull alpine:latest
docker tag alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
docker push ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1

docker tag alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.2
docker push ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.2

docker tag alpine:latest ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.3
docker push ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.3

docker rmi alpine:latest
docker rmi ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
#docker image ls
#docker pull ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1
#docker run -i ${ACR_REGISTRY_NAME}.azurecr.io/alpinetest:0.1

#Show the current repository attributes
az acr repository show \
--name ${ACR_REGISTRY_NAME} \
--repository alpinetest

#Show the image attributes
DIGEST=$(echo $(az acr repository show \
--name ${ACR_REGISTRY_NAME} \
--image alpinetest:0.1 \
--query "digest" \
--output tsv) | tr -d "\t\r\n ")
echo $DIGEST

az acr manifest list --registry ${ACR_REGISTRY_NAME} --name alpinetest
az acr manifest show --registry ${ACR_REGISTRY_NAME} --name alpinetest:0.2
az acr manifest show-metadata --registry ${ACR_REGISTRY_NAME} --name alpinetest:0.2

#Prevent deleting
az acr manifest update-metadata --registry ${ACR_REGISTRY_NAME} --name alpinetest:0.2 --delete-enabled false

az acr repository delete \
--name ${ACR_REGISTRY_NAME} \
--image alpinetest:0.2
#--image alpinetest@${DIGEST}

#Allow deleting
az acr manifest update-metadata --registry ${ACR_REGISTRY_NAME} --name alpinetest:0.2 --delete-enabled true

az acr repository delete \
--name ${ACR_REGISTRY_NAME} \
--image alpinetest:0.2

az group delete --name ${RESOURCE_GROUP} --no-wait
