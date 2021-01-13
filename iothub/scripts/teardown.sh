#!/bin/bash
groupName="IoTHubDemo"
echo "removing objects from azure..."
az group delete -n $groupName -y
echo "done!"
