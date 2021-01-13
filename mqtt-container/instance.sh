#!/bin/bash

# Variables
groupName="MosquittoDemo"
containerName="mosquitto-container"
location="WestUS"
dockerHubContainerPath="eclipse-mosquitto:latest"

# Create a Resource Group
echo "creating resource group..."
az group create \
	--name $groupName \
	--location $location

# Create a Container Instance
echo "creating instance..."
INSTANCE=`az container create \
	--resource-group $groupName \
	--name $containerName \
	--image $dockerHubContainerPath \
	--ports 1883 9001 \
	--ip-address Public \
	--protocol TCP`

# Print the IP
IPLINE=`echo $INSTANCE | grep -o "\"ip\": \"[0-9.]*\""`
IP=`echo $IPLINE | grep -o "[0-9.]*"`
echo "ip: $IP"
