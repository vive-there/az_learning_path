#!/bin/bash
#Deploy a container instance in Azure using the Docker CLI

#Create an Azure resource group

#docker login azure --tenant-id [your-tenant]

#Select a resource group during creating
#docker context create aci [contextname]

#docker context ls

#docker context use [contextname]

#Run some image
#docker run --name [containername] -p 80:80 mcr.microsoft.com/azuredocs/aci-helloworld

#docker ps

#to do something with running container [containername]

#Remove container
#docker rm [containername] --force

#Switch context
#docker context use default

#Remove context
#docker context rm [contextname]

#Check if ACI has been removed in a resource group

