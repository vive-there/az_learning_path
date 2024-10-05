#!/bin/bash

RANDOM_SUFFIX=${RANDOM}
LOCATION=eastus
RG_NAME=az204_sa${RANDOM_SUFFIX}
SA_NAME=vivetheresa${RANDOM_SUFFIX}
KV_NAME=vivetherekv${RANDOM_SUFFIX}
KV_KEY_NAME=sakey

USER_ID=$(echo $(az ad signed-in-user show --query id -o tsv) | tr -d '\t\r\n')

az group create --name ${RG_NAME} --location ${LOCATION}

az keyvault create \
--name ${KV_NAME} \
--resource-group ${RG_NAME} \
--enable-purge-protection true \
--enable-rbac-authorization true \
--location ${LOCATION} \
--retention-days 7

echo "Sleep 10s ..."
sleep 10s

KV_ID=$(echo $(az keyvault show --name ${KV_NAME} --resource-group ${RG_NAME} --query id -o tsv) | tr -d '\t\r\n')

az role assignment create \
--role 'Key Vault Crypto Officer' \
--scope ${KV_ID} \
--assignee-object-id ${USER_ID} \
--assignee-principal-type User

echo "Sleep 10s ..."
sleep 10s

az keyvault key create \
--vault-name ${KV_NAME} \
--name ${KV_KEY_NAME}


az storage account create \
--name ${SA_NAME} \
-g ${RG_NAME} \
--location ${LOCATION} \
--kind StorageV2 \
--sku Standard_LRS







