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
iotHubName=${AZ_RESOURCE_GROUP_NAME}_IoTHub
echo "iot hub name: " $iotHubName
# Create the IoT hub.
az iot hub create \
	--name $iotHubName \
    	--resource-group $resourceGroup \
    	--sku S1 \
	--location $location

echo "creating consumer group..."
# Add a consumer group to the IoT hub for the 'events' endpoint.
az iot hub consumer-group create \
	--hub-name $iotHubName \
    	--name $iotHubConsumerGroup

echo "creating storage account..."
storageAccountName=iottrainingstorage$rand
# Create the storage account to be used as a routing destination.
az storage account create \
	--name $storageAccountName \
    	--resource-group $resourceGroup \
    	--location $location \
    	--sku Standard_LRS
echo "storage account name: " $storageAccountName

echo "getting storage account key..."
# Get the primary storage account key.
#    You need this to create the container.
storageAccountKey=$(az storage account keys list \
    	--resource-group $resourceGroup \
    	--account-name $storageAccountName \
    	--query "[0].value" | tr -d '"')
# See the value of the storage account key.
echo "storage account key: " $storageAccountKey

echo "creating storage container..."
# Create the container in the storage account.
az storage container create \
	--name $containerName \
    	--account-name $storageAccountName \
    	--account-key $storageAccountKey \
    	--public-access off

echo "creating service bus namespace..."
sbNamespace=IoTTrainingSBNamespace$rand
# Create the Service Bus namespace.
az servicebus namespace create \
	--resource-group $resourceGroup \
    	--name $sbNamespace \
    	--location $location
echo "service bus namespace: " $sbNamespace

echo "creating service bus queue..."
sbQueueName=IoTTrainingSBQueue$rand
# Create the Service Bus queue to be used as a routing destination.
az servicebus queue create \
	--name $sbQueueName \
    	--namespace-name $sbNamespace \
    	--resource-group $resourceGroup
echo "service bus queue name: " $sbQueueName

endpointName="TrainingStorageEndpoint"
endpointType="azurestoragecontainer"
routeName="IoTTrainingStorageRoute"
condition='level="storage"'

echo "creating storage message endpoint and route..."
storageConnectionString=$(az storage account show-connection-string \
  --name $storageAccountName --query connectionString -o tsv)

# Create the routing endpoint for storage.
az iot hub routing-endpoint create \
  --connection-string $storageConnectionString \
  --endpoint-name $endpointName \
  --endpoint-resource-group $resourceGroup \
  --endpoint-subscription-id $subscriptionID \
  --endpoint-type $endpointType \
  --hub-name $iotHubName \
  --container $containerName \
  --resource-group $resourceGroup \
  --encoding avro

# Create the route for the storage endpoint.
az iot hub route create \
  --name $routeName \
  --hub-name $iotHubName \
  --source devicemessages \
  --resource-group $resourceGroup \
  --endpoint-name $endpointName \
  --enabled \
  --condition $condition

echo "creating a service bus endpoint and route..."
# Create the authorization rule for the Service Bus queue.
az servicebus queue authorization-rule create \
  --name "sbauthrule" \
  --namespace-name $sbNamespace \
  --queue-name $sbQueueName \
  --resource-group $resourceGroup \
  --rights Listen Manage Send \
  --subscription $subscriptionID

# Get the Service Bus queue connection string.
# The "-o tsv" ensures it is returned without the default double-quotes.
sbqConnectionString=$(az servicebus queue authorization-rule keys list \
  --name "sbauthrule" \
  --namespace-name $sbNamespace \
  --queue-name $sbQueueName \
  --resource-group $resourceGroup \
  --subscription $subscriptionID \
  --query primaryConnectionString -o tsv)

# Show the Service Bus queue connection string.
echo "service bus queue connection string: " $sbqConnectionString

endpointName="TrainingSBQueueEndpoint"
endpointType="ServiceBusQueue"
routeName="IoTTrainingSBQueueRoute"
condition='level="queue"'

# Set up the routing endpoint for the Service Bus queue.
# This uses the Service Bus queue connection string.
az iot hub routing-endpoint create \
  --connection-string $sbqConnectionString \
  --endpoint-name $endpointName \
  --endpoint-resource-group $resourceGroup \
  --endpoint-subscription-id $subscriptionID \
  --endpoint-type $endpointType \
  --hub-name $iotHubName \
  --resource-group $resourceGroup

# Set up the message route for the Service Bus queue endpoint.
az iot hub route create --name $routeName \
  --hub-name $iotHubName \
  --source-type devicemessages \
  --resource-group $resourceGroup \
  --endpoint-name $endpointName \
  --enabled \
  --condition $condition

echo "creating demo device..."
# Create the IoT device identity to be used for demoing.
az iot hub device-identity create  \
	--hub-name $iotHubName \
	--auth-method x509_ca \
	--device-id $iotDeviceUUID \
# Retrieve the information about the device identity, then copy the primary key to
#   Notepad. You need this to run the device simulation during the testing phase.
echo "device details: "
az iot hub device-identity show \
	--device-id $iotDeviceUUID \
    	--hub-name $iotHubName

echo "done!"
