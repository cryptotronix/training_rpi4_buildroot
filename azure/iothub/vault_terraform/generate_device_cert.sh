#!/usr/bin/env bash

set -e

vault write pki/issue/device common_name=$AZ_DEVICE_UUID
