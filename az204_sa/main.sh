#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP=az204-sa${RANDOM_SUFFIX}
LOCATION=eastus
STORAGE_ACCOUNT_NAME=vivethere${RANDOM_SUFFIX}


az group create --name ${RESOURCE_GROUP} --location ${LOCATION}

az storage account create --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --kind StorageV2 --sku Standard_LRS

SA_KEY=$(echo $(az storage account keys list --account-name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --query "[?keyName=='key1'].value" -o tsv) | tr -d '\n\t\r')
EXPIRE_DATETIME=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

echo ${SA_KEY}
echo ${EXPIRE_DATETIME}
