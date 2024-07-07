#!/bin/bash
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="apim_rg"$RANDOM_SUFFIX
LOCATION="eastus2"
APIM_NAME=vivethere${RANDOM_SUFFIX}
MYDEMO_API_ID=mydemo
VERSIONSET_ID=my-demo-api-verset
# export file name format
OPENAPIJSON_LOCALFILE=${MYDEMO_API_ID}_openapi+json.json

az group create \
--name ${RESOURCE_GROUP} \
--location ${LOCATION}

az apim create \
--name ${APIM_NAME} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--sku-name Consumption \
--publisher-name "Vadym Tarasov" \
--publisher-email vadym.tarasov@gmail.com

# create an empty API
az apim api create \
--service-name ${APIM_NAME} \
--resource-group ${RESOURCE_GROUP} \
--api-id ${MYDEMO_API_ID} \
--display-name "My Demo API" \
--path "/mydemoapi"

# create a mockup GET operation
az apim api operation create \
--service-name ${APIM_NAME} \
--api-id ${MYDEMO_API_ID} \
--resource-group ${RESOURCE_GROUP} \
--display-name "Get Contributors" \
--description "Get list of contributors" \
--url-template "/contributors" \
--method GET \
--operation-id getcontributors

# # create version set 
# az apim api versionset create \
# --service-name ${APIM_NAME} \
# --resource-group ${RESOURCE_GROUP} \
# --display-name "My Demo API VersionSet" \
# --version-set-id "${VERSIONSET_ID}" \
# --versioning-scheme "Segment"

# az apim api export \
# --service-name ${APIM_NAME} \
# --resource-group ${RESOURCE_GROUP} \
# --api-id ${MYDEMO_API_ID} \
# --export-format OpenApiJsonFile \
# --file-path ${PWD}
# # or OpenApiJsonUrl 

# # create a new version 
# VERSION2=v2

# az apim api import \
# --service-name ${APIM_NAME} \
# -g ${RESOURCE_GROUP} \
# --specification-format OpenApiJson \
# --specification-path "${PWD}/${OPENAPIJSON_LOCALFILE}" \
# --api-id ${MYDEMO_API_ID}${VERSION2} \
# --display-name "My Demo API ${VERSION2}" \
# --api-version-set-id ${VERSIONSET_ID} \
# --path contributors \
# --api-version ${VERSION2}


# cat ${PWD}/${OPENAPIJSON_LOCALFILE}

echo ${RESOURCE_GROUP}
echo ${APIM_NAME}
echo ${MYDEMO_API_ID}

# rm ${PWD}/${OPENAPIJSON_LOCALFILE}


import --service-url "https://conferenceapi.azurewebsites.net/?format=json"
az apim api import \
--service-name ${APIM_NAME} \
--resource-group ${RESOURCE_GROUP} \
--specification-format OpenApiJson \
--path democonferenceapi \
--specification-url https://conferenceapi.azurewebsites.net/?format=json


