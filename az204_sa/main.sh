#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP=az204-sa${RANDOM_SUFFIX}
LOCATION=eastus
STORAGE_ACCOUNT_NAME=vivethere${RANDOM_SUFFIX}
CONTAINER_NAME=test
BLOB_NAME=blobaz

az group create --name ${RESOURCE_GROUP} --location ${LOCATION}

az storage account create --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --kind StorageV2 --sku Standard_LRS

STORAGE_ACCOUNT_ID=$(echo $(az storage account show --name ${STORAGE_ACCOUNT_NAME} -g ${RESOURCE_GROUP} --query id -o tsv) | tr -d '\n\r\t')
USER_ID=$(echo $(az ad signed-in-user show --query id -o tsv) | tr -d '\n\r\t')

az role assignment create \
--assignee-object-id ${USER_ID} \
--assignee-principal-type User \
--role "Storage Blob Data Contributor" \
--scope ${STORAGE_ACCOUNT_ID}

az storage container create \
--name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--auth-mode login

az storage blob upload \
--auth-mode login \
--container-name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--name readme.MD \
--file ./readme.MD

az storage blob list \
--auth-mode login \
--container-name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME}

az storage blob download \
--auth-mode login \
--container-name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--name readme.MD \
--file ./readme${RANDOM_SUFFIX}.MD




# SA_KEY=$(echo $(az storage account keys list --account-name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --query "[?keyName=='key1'].value" -o tsv) | tr -d '\n\t\r')
# EXPIRE_DATETIME=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

# echo ${SA_KEY}
# echo ${EXPIRE_DATETIME}
