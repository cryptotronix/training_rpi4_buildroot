#!/bin/bash

url="test-hub-275af2fa-080f-11eb-87c0-c70b185c01db.azure-devices.net"
device="fcbf4c34-79f0-485c-bdc1-5dcc746c3223"
device2="5c6f258d-1952-42f1-a1ba-e314202f495e"
ca="azureca.pem"
cert="device2.pem"
key="device2.pem"

mosquitto_sub \
	-d \
	-h $url \
	-p 8883 \
	-i $device \
	-u "$url/$device/?api-version=2018-06-30" \
	-t "devices/$device/messages/devicebound/#" \
	-V mqttv311 \
	--cafile $ca \
	--cert $cert \
	--key $key \
	-q 1
