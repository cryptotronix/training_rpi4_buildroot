#!/bin/bash
groupName="MosquittoDemo"
echo "removing objects from azure..."
az group delete -n $groupName -y
echo "done!"
