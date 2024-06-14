#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP="aci_rg"${RANDOM_SUFFIX}
LOCATION="eastus"
CONTAINER_NAME=vtaci${RANDOM_SUFFIX}
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az container create \
--name ${CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image mcr.microsoft.com/azuredocs/aci-helloworld \
--dns-name-label ${CONTAINER_NAME} \
--ports 80

# az container show \
# --name ${CONTAINER_NAME} \
# --resource-group ${RESOURCE_GROUP} \
# --query "{FQDN:ipAddress.fqdn,Status:provisioningState}" \
# -o table

# az container list \
# --name ${CONTAINER_NAME} \
# --resource-group ${RESOURCE_GROUP}

# az container logs \
# --name ${CONTAINER_NAME} \
# --resource-group ${RESOURCE_GROUP}

# az container attach \
# --name ${CONTAINER_NAME} \
# --resource-group ${RESOURCE_GROUP}

# az container delete \
# --name ${CONTAINER_NAME} \
# --resource-group ${RESOURCE_GROUP}