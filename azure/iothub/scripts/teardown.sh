#!/bin/bash

set -e

if [ -z $AZ_RESOURCE_GROUP_NAME ];then
	echo "please set AZ_RESOURCE_GROUP_NAME. exiting..."
	exit 1
fi

echo "removing objects from azure..."
az group delete -n $AZ_RESOURCE_GROUP_NAME -y
echo "done!"
