#!/bin/bash

RESOURCE_GROUP=$1
RANDOM_SUFFIX=$2
KV_NAME=vivetherekv${RANDOM_SUFFIX}
LOCATION=$(echo $(az group show --name ${RESOURCE_GROUP} --query location -o tsv) | tr -d '\t\r\n')
KEY_NAME=vtkey${RANDOM_SUFFIX}

echo "Create keyvault ${KV_NAME}"
az keyvault create \
--name $KV_NAME \
--location $LOCATION \
--resource-group $RESOURCE_GROUP \
--sku standard \
--retention-days 7 \
--enable-rbac-authorization true \
--enable-purge-protection

# Give yourself the Key Vault Secrets Officer RBAC role for the vault.
# Remove end of line from string
VAULT_ID=$(echo $(az keyvault show --name $KV_NAME -g $RESOURCE_GROUP --query id --output tsv) | tr -d '\n\t\r ')
SP_ID=$(echo $(az ad signed-in-user show --query id -o tsv) | tr -d '\n\t\r ')

az role assignment create \
--role "Key Vault Crypto Officer" \
--assignee-object-id $SP_ID \
--assignee-principal-type User \
--scope $VAULT_ID

while true; do
  PrincipalName=$(echo $(
    az role assignment list \
    --role 'Key Vault Crypto Officer' \
    --assignee $SP_ID \
    --scope $VAULT_ID \
    --query [].principalName \
    -o tsv
  ) | tr -d '\t\r\n ')
  if [[ ! -z "$PrincipalName" ]] 
  then
    break
  fi
done

az keyvault key create \
--name $KEY_NAME \
--vault-name $KV_NAME




