#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="aci_rg"${RANDOM_SUFFIX}
LOCATION="eastus"

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az container create \
--resource-group ${RESOURCE_GROUP} \
--file ./scripts/aci/multi_container_group.yaml

az container show --resource-group ${RESOURCE_GROUP} --name vtContainerGroup --output table
 az container logs --resource-group ${RESOURCE_GROUP} --name vtContainerGroup --container-name aci-tutorial-app
 az container logs --resource-group ${RESOURCE_GROUP} --name vtContainerGroup --container-name aci-tutorial-sidecar