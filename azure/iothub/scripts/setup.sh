#!/bin/bash

set -e

if [ -z $AZ_RESOURCE_GROUP_NAME ];then
	echo "please set AZ_RESOURCE_GROUP_NAME. exiting..."
	exit 1
fi
if [ -z $AZ_DEVICE_UUID ];then
	echo "please set AZ_DEVICE_UUID. exiting..."
	exit 1
fi

# This command retrieves the subscription id of the current Azure account.
subscriptionID=$(az account show --query id -o tsv)

rand=$RANDOM

az extension add --name azure-iot

location=westus
resourceGroup=$AZ_RESOURCE_GROUP_NAME
iotHubConsumerGroup=IoTTrainingConsGroup$rand
containerName=iottraining-storage-container$rand
iotDeviceUUID=$AZ_DEVICE_UUID

echo "creating resource group..."
az group create \
	--name $resourceGroup \
	--location $location

echo "creating iot hub..."
iotHubName=${AZ_RESOURCE_GROUP_NAME}-IoTHub
echo "iot hub name: " $iotHubName
# Create the IoT hub.
az iot hub create \
	--name $iotHubName \
    	--resource-group $resourceGroup \
    	--sku S1 \
	--location $location
