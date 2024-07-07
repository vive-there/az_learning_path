#!/bin/bash
# Build from source context
RANDOM_SUFFIX=${RANDOM}
RESOURCE_GROUP="aci_rg"${RANDOM_SUFFIX}
LOCATION="eastus"
CONTAINER_NAME=vtaci${RANDOM_SUFFIX}
VNET_NAME=vtnet${RANDOM_SUFFIX}
SUBNET_NAME=vtsubnet${RANDOM_SUFFIX}
THE_SECOND_CONTAINER_NAME=vtacisecond${RANDOM_SUFFIX}

# Create a resource group
az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

# The subnet that you use for container groups can contain only container groups. 
# Before you deploy a container group to a subnet, you must explicitly delegate the subnet before provisioning. 
# Once delegated, the subnet can be used only for container groups. 
# If you attempt to deploy resources other than container groups to a delegated subnet, the operation fails.
az network vnet create \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--name ${VNET_NAME} \
--address-prefixes 10.0.0.0/16 \
--subnet-name ${SUBNET_NAME} \
--subnet-prefixes 10.0.0.0/24 


# Deploy a container group for a existed virtual network and subnet
az container create \
--name ${CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image  mcr.microsoft.com/azuredocs/aci-helloworld \
--vnet ${VNET_NAME} \
--subnet ${SUBNET_NAME}

# Get container group IP address
CONTAINER_GROUP_IP=$(echo $(az container show \
--name ${CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} \
--query ipAddress.ip \
--output tsv) | tr -d '\n')

echo ${CONTAINER_GROUP_IP}

# The following example deploys a second container group to the same subnet created previously, 
# and verifies communication between the two container instances.
az container create \
--name ${THE_SECOND_CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} \
--image alpine:3.5 \
--command-line "wget $CONTAINER_GROUP_IP" \
--restart-policy never \
--vnet ${VNET_NAME} \
--subnet ${SUBNET_NAME}

az container logs \
--name ${THE_SECOND_CONTAINER_NAME} \
--resource-group ${RESOURCE_GROUP} 

