#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="aci_rg"${RANDOM_SUFFIX}
LOCATION="eastus"
ACR_REGISTRY_NAME="vivethereacr"${RANDOM_SUFFIX}
LOCAL_GIT_DIR=${HOME}/azure/repos/aci-helloworld
IMAGE_NAME=aci-tutorial-app
APP_NAME=v${IMAGE_NAME}
APP_VER=1.0
SP_USER_NAME=vtun${RANDOM_SUFFIX}

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

#Create acr with admin enabled
az acr create \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--sku Basic \
--admin-enabled true

az acr login \
--name ${ACR_REGISTRY_NAME}

# Build docker image
docker build ${LOCAL_GIT_DIR}/. -t ${IMAGE_NAME}
#test
#docker run -d -p 8080:80 ${IMAGE_NAME} --name cnt-&{IMAGE_NAME}
docker tag ${IMAGE_NAME} ${ACR_REGISTRY_NAME}.azurecr.io/${APP_NAME}:${APP_VER}
docker push ${ACR_REGISTRY_NAME}.azurecr.io/${APP_NAME}:${APP_VER}
#docker rmi ${IMAGE_NAME} ${ACR_REGISTRY_NAME}.azurecr.io/${APP_NAME}:${APP_VER} --force

# az acr repository list \
# --name ${ACR_REGISTRY_NAME} \
# --output table

# az acr repository show-tags \
# --name ${ACR_REGISTRY_NAME} \
# --repository ${APP_NAME} \
# --output table

ACR_LOGIN_SERVER=$(echo $(az acr show \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--query loginServer \
--output tsv) | tr -d '\n\t\r')

ACR_ID=$(echo $(az acr show \
--name ${ACR_REGISTRY_NAME} \
--resource-group ${RESOURCE_GROUP} \
--query id \
--output tsv) | tr -d '\n\t\r')

echo "ACR_LOGIN_SERVER ${ACR_LOGIN_SERVER}"
echo "ACR_ID ${ACR_ID}"

#Create service principal with role acrpull for acr and return pwd
SP_PASSWORD=$(echo $(az ad sp create-for-rbac \
--name ${SP_USER_NAME} \
--role acrpull \
--scopes ${ACR_ID} \
--query password \
--output tsv) | tr -d '\n\t\r')

echo "pause for 15 secs"
sleep 15

#Get service principal id
SP_ID=$(echo $(az ad sp list \
--display-name ${SP_USER_NAME} \
--query [].appId \
--output tsv) | tr -d '\n\t\r')

echo "principal id ${SP_ID}"

#Create container
az container create \
--name container-${APP_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image ${ACR_REGISTRY_NAME}.azurecr.io/${APP_NAME}:${APP_VER} \
--registry-login-server ${ACR_LOGIN_SERVER} \
--registry-username ${SP_ID} \
--registry-password ${SP_PASSWORD} \
--dns-name-label ${APP_NAME} \
--ports 80 \
--ip-address Public \
--query "{FQDN:ipAddress.fqdn}" \
--output table

az container logs \
--name container-${APP_NAME} \
--resource-group ${RESOURCE_GROUP} 
