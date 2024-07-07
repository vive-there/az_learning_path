#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP="aci_rg"${RANDOM_SUFFIX}
LOCATION="eastus"
CONTAINER_NAME=vtaci${RANDOM_SUFFIX}
VNET_NAME=vtnet${RANDOM_SUFFIX}
VSUBNET_NAME=vtsubnet${RANDOM_SUFFIX}

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

# Deploy a container group for a new virtual network and subnet
az container create \
--name ${CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image  mcr.microsoft.com/azuredocs/aci-helloworld \
--vnet ${VNET_NAME} \
--vnet-address-prefix 10.0.0.0/16 \
--subnet ${VSUBNET_NAME} \
--subnet-address-prefix 10.0.0.0/24

