#!/bin/bash

# Variables
groupName="IoTHubDemo"
hubName="test-hub-275af2fa-080f-11eb-87c0-c70b185c01db"
device_uuid=`uuid`

# Create a x509 verified device
echo "creating iot hub..."
az iot hub device-identity create  \
	--name $hubName \
	--auth-method x509_ca \
	--device-id $device_uuid \

echo "done!"
