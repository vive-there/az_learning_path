#!/bin/bash
# Build from source context
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="acrbuild_rg"$RANDOM_SUFFIX
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacrbuild1"$RANDOM_SUFFIX
APP_NAME=vthelloacrtasks
APP_VER=1.0
KEYVAULT_NAME=vivetherekv$RANDOM_SUFFIX
# Service principal name for PULL role
SP_PULL="${ACR_REGISTRY_NAME}-pull"


echo "Creating resource group ${RESOURCE_GROUP}"
az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

echo "Creating ACR ${ACR_REGISTRY_NAME}"
az acr create \
--name $ACR_REGISTRY_NAME \
--resource-group $RESOURCE_GROUP \
--sku Basic

echo "Build image ${APP_NAME}:${APP_VER} from file context"
echo "ACR tasks automatically push successfully built images to your registry by default"
az acr build \
--registry $ACR_REGISTRY_NAME \
--resource-group $RESOURCE_GROUP \
--image ${APP_NAME}:${APP_VER} \
--file ~/azure/repos/acr-build-helloworld-node/Dockerfile \
~/azure/repos/acr-build-helloworld-node/.

# Deploy to Azure Container Instances
echo "Create keyvault ${KEYVAULT_NAME}"
az keyvault create \
-g $RESOURCE_GROUP \
--name $KEYVAULT_NAME \
--retention-days 7 \
--sku standard \
--enable-rbac-authorization true

# Give yourself the Key Vault Secrets Officer RBAC role for the vault.
# Remove end of line from string
VAULT_ID=$(echo $(az keyvault show --name $KEYVAULT_NAME -g $RESOURCE_GROUP --query id --output tsv) | tr -d '\n\t\r ')
MY_ID=$(echo $(az ad signed-in-user show --query id -o tsv) | tr -d '\n\t\r ')

az role assignment create \
--role "Key Vault Secrets Officer" \
--assignee-object-id $MY_ID \
--assignee-principal-type User \
--scope $VAULT_ID


echo "Get ACR ID"
ACR_REGISTRY_ID=$(echo $(az acr show --name $ACR_REGISTRY_NAME --resource-group $RESOURCE_GROUP --query id --output tsv) | tr -d '\n\t\r ')

echo "Create a service principal and configure the service principal with the acrpull role, which grants it pull-only access to the registry."
SP_PASSWORD=$(echo $(az ad sp create-for-rbac --name $SP_PULL --role acrpull --scopes $ACR_REGISTRY_ID --query password -o tsv) | tr -d '\n\t\r')

echo "Store its password in AKV"
az keyvault secret set \
--vault-name $KEYVAULT_NAME \
--name $ACR_REGISTRY_NAME-pull-pwd \
--value $SP_PASSWORD

echo "Get service principal id"
SP_ID=$(echo $(az ad sp list --display-name $SP_PULL --query [].appId --output tsv) | tr -d '\n\t\r')

echo "Store service principal ID in AKV"
az keyvault secret set \
--vault-name $KEYVAULT_NAME \
--name $ACR_REGISTRY_NAME-pull-usr \
--value $SP_ID

echo "Deploy a container instance"
az container create \
-g $RESOURCE_GROUP \
--name acitasks \
--image ${ACR_REGISTRY_NAME}.azurecr.io/${APP_NAME}:${APP_VER} \
--registry-login-server ${ACR_REGISTRY_NAME}.azurecr.io \
--registry-username $(echo $(az keyvault secret show --name ${ACR_REGISTRY_NAME}-pull-usr --vault-name ${KEYVAULT_NAME} --query value -o tsv) | tr -d '\r\n\t') \
--registry-password $(echo $(az keyvault secret show --name ${ACR_REGISTRY_NAME}-pull-pwd --vault-name ${KEYVAULT_NAME} --query value -o tsv) | tr -d '\r\n\t') \
--dns-name-label acr-tasks-${ACR_REGISTRY_NAME} \
--query "{FQDN:ipAddress.fqdn}" \
--output table





















