#!/bin/bash

url="IoTTestHub16838.azure-devices.net"
device="2a065b19-978a-4204-9a0c-2ea9612834c8"
ca="azureca.pem"
cert="device3.pem"
key="device3.pem"

mosquitto_pub \
	-d \
	-h $url \
	-p 8883 \
	-i $device \
	-u "$url/$device/?api-version=2018-06-30" \
	-m '{"level":"critical", "body":"hello world"}' \
	-t "devices/$device/messages/events/" \
	-V mqttv311 \
	--cafile $ca \
	--cert $cert \
	--key $key \
	-q 1
#-t "devices/$device/messages/events/" \
