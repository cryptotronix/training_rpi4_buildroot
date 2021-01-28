#!/bin/bash

set -e

echo "removing objects from azure..."
az group delete -n $AZ_RESOURCE_GROUP_NAME -y
echo "done!"
