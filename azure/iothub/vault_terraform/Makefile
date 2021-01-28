.PHONY: all

all: check_target_envs init plan apply

check_target_envs:
	@if [ -z "$(VAULT_ADDR)" ]; then echo "VAULT_ADDR not set, exiting."; exit 1; fi

init:
	terraform init

plan: check_target_envs
	terraform plan -out plan.bin

apply: check_target_envs
	terraform apply

perform_pop:
	@if [ -z "$(AZ_POP_CODE)" ]; then echo "AZ_POP_CODE not set, exiting."; exit 1; fi
	./perform_PoP.sh

gen_device_cert:
	@if [ -z "$(AZ_DEVICE_UUID)" ]; then echo "AZ_DEVICE_UUID not set, exiting."; exit 1; fi
	./generate_device_cert.sh
