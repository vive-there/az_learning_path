#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP=az204-sa${RANDOM_SUFFIX}
LOCATION=eastus
STORAGE_ACCOUNT_NAME=vivethere${RANDOM_SUFFIX}
CONTAINER_NAME=test
BLOB_NAME=blobaz

echo "Creating RG ${RESOURCE_GROUP}"
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}

echo "Creating SA ${STORAGE_ACCOUNT_NAME}"
az storage account create --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --kind StorageV2 --sku Standard_LRS

STORAGE_ACCOUNT_ID=$(echo $(az storage account show --name ${STORAGE_ACCOUNT_NAME} -g ${RESOURCE_GROUP} --query id -o tsv) | tr -d '\n\r\t')
USER_ID=$(echo $(az ad signed-in-user show --query id -o tsv) | tr -d '\n\r\t')

echo "Creating role assignment"
az role assignment create \
--assignee-object-id ${USER_ID} \
--assignee-principal-type User \
--role "Storage Blob Data Contributor" \
--scope ${STORAGE_ACCOUNT_ID}

echo "Creating container ${CONTAINER_NAME}"
az storage container create \
--name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--auth-mode login

echo "Uploading file ..."
az storage blob upload \
--auth-mode login \
--container-name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--name readme.MD \
--file ./readme.MD

echo "List contents of conatiner ${CONTAINER_NAME}"
az storage blob list \
--auth-mode login \
--container-name ${CONTAINER_NAME} \
--account-name ${STORAGE_ACCOUNT_NAME} \
--query "[].{Name:name,Created:properties.creationTime, Modified:properties.lastModified}" 

# echo "Downloading file ..."
# az storage blob download \
# --auth-mode login \
# --container-name ${CONTAINER_NAME} \
# --account-name ${STORAGE_ACCOUNT_NAME} \
# --name readme.MD \
# --file ./readme${RANDOM_SUFFIX}.MD

echo "The End"

# SA_KEY=$(echo $(az storage account keys list --account-name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --query "[?keyName=='key1'].value" -o tsv) | tr -d '\n\t\r')
# EXPIRY_DATETIME=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

# echo ${SA_KEY}
# echo ${EXPIRY_DATETIME}

# az storage container generate-sas --name [container name] --account-name ${STORAGE_ACCOUNT_NAME} --account-key $SA_KEY --expiry $EXPIRY_DATETIME --permissions r --https-only
