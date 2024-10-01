#!/bin/bash
SUFIX=$1
RESOURCE_GROUP=az204-sa$SUFIX
LOCATION=eastus
STORAGE_ACCOUNT_NAME=vivethere$SUFIX
CONTAINER_NAME=test

SA_KEY=$(echo $(az storage account keys list --account-name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} --query "[?keyName=='key1'].value" -o tsv) | tr -d '\t\r\n')
EXPIRY_DATETIME=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

# create user managed identity
# az identity create --name [UI NAME] -g [RG NAME]
# USER_MANAGED_ID=$(echo $(az identity show --name [user managed name] --resource-group [rg name] --query id -o tsv) | tr -d '\t\r\n')
# USER_MANAGED_PRINCIPALID=$(echo $(az identity show --name [user managed name] --resource-group [rg name] --query prinicpalId -o tsv) | tr -d '\t\r\n')
# az role assignment create \
# --role "Key Vault Crypto Service Encryption User" \
# --assignee-object-id $USER_MANAGED_PRINCIPALID \
# --scope $VAULT_ID \
# --assignee-principal-type User

# or set system managed identity to sa
# az storage account update --name [SA NAME] --resource-group [RG NAME] --assign-identity
# SA_PRINCIPALID=$(echo $(az storage account show --name [SA NAME] -g [RG NAME] --query identity.principalId -o tsv) | tr -d '\n\t\r')
# VAULT_ID=$(echo $(az keyvault show --name [SA NAME] --resource-group [RG NAME] --query id -o tsv) | tr -d '\n\t\r')
# az role assignment create --role "Key Vault Crypto Service Encryption User" --assignee-object-id $SA_PRINCIPALID --scope $VAULT_ID --assignee-principal-type ServicePrincipal

# Configure encryption for automatic updating of key versions
# VAULT_URI=$(echo $(az keyvault show --name [KV NAME] -g [RG NAME] --query properties.vaultUri -o tsv) | tr -d '\t\r\n')
# managed encryption by system assigned 
#
# az storage account update \
# --name [SA NAME] \
# -g [RG NAME] \
# --encryption-key-source Microsoft.Keyvault \
# --encryption-key-vault $VAULT_URI \
# --encryption-key-name [KV KEY NAME] \
# --encryption-key-version "" \
# --identity-type SystemAssigned
#
# OR managed encryption by user managed
#
# az storage account update \
# --name [SA NAME] \
# -g [RG NAME] \
# --encryption-key-source Microsoft.Keyvault \
# --encryption-key-vault $VAULT_URI \
# --encryption-key-name [KV KEY NAME] \
# --encryption-key-version "" \
# --identity-type UserAssigned \
# --user-identity-id $USER_MANAGED_ID \
# --key-vault-user-identity-id $USER_MANAGED_ID