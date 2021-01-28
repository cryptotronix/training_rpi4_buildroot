#!/usr/bin/env bash

oset -e
vault write pki/issue/device common_name=$DEVICE_UUID
