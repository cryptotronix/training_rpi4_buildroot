# Using the Azure IOT Hub Demo

## Setup

### Azure Resources

To create the necessary resources in Azure, we first have to log into the azure CLI.

```
$ az login
```


This will open up a webpage to allow you to log into your azure account.

Once we are logged in, we can then setup the required environment variables for the setup script. The template can be found at `scripts/templates/setup.template`. WARNING: when you choose a value for `AZ_RESOURCE_GROUP_NAME` ensure that it uses a unique identifier, as it MUST be unique. `AZ_DEVICE_UUID` is self-explanitory, simply generate a uuid.

Once you have set the required env vars, we can now run setup.

```
$ ./scripts/setup.sh
```

Now that the resources have been generated on your Azure account, we must now create, upload, and verify a CA for the IoT Hub.


### Vault Cert Generation


To create the CA and issue the required certificates for this demo, we will use Vault and Terraform. Please make sure that you have a running instance of Vault with admin/root access, and access to `terraform`.

First, please ensure that you have set `VAULT_ADDR` in your environment and that you have authenticated with vault (be that with logging in or with `VAULT_TOKEN`).

With vault credentials taken care of, we can then run terraform:

```
cd ./vault_terraform
make all
```


With the Vault instance initialized, we can now create the required device certificate.

NOTE: if you don't have `AZ_DEVICE_UUID` still set from a previous step, do so now.

```
make gen_device_cert
```

The output from this command should look somewhat like this:

```
Key                 Value
---                 -----
certificate         -----BEGIN CERTIFICATE-----
		    *snip*
		    -----END CERTIFICATE-----
expiration          1614420311
issuing_ca          -----BEGIN CERTIFICATE-----
                    *snip*
		    -----END CERTIFICATE-----
private_key         -----BEGIN EC PRIVATE KEY-----
                    *snip*
		    -----END EC PRIVATE KEY-----

```

Save the `certificate` and the `private_key` in a single file, as we will use that to authenticate the device later. Then, save the `issuing_ca` as its own file (with the `.pem` extension, necessary for Azure) as we will be using it in the next step.


### Uploading the CA and Proof of Possession

We now need to upload the CA generated in the previous step to Azure.

Simply navigate to your Resource Group (with the name you provided earlier), and access your IoT Hub resource. Click on the `Certificates` option in the sidebar, and click `Add`. Name the CA whatever you wish, and then select the file containing the CA generated in the previous step.

Now, click on the CA listing, scroll to the bottom of the `Certificate Details` menu that has appeared, and select `Generate Verification Code`. We will now use this verification code and generate the required proof using our Vault instance.

Set the `AZ_POP_CODE` environment variable to the `Verification Code` that was provided by Azure, and then in the `vault_terraform` directory run the following:

```
$ make perform_pop
```

You will recieve an output similar to before, but this time we only need the `certificate`:

```
Key                 Value
---                 -----
certificate         -----BEGIN CERTIFICATE-----
		    *snip*
		    -----END CERTIFICATE-----
expiration          1614420311
issuing_ca          -----BEGIN CERTIFICATE-----
                    *snip*
		    -----END CERTIFICATE-----
private_key         -----BEGIN EC PRIVATE KEY-----
                    *snip*
		    -----END EC PRIVATE KEY-----

```

This certificate will be used as the verification that Azure requires, so we can now upload this certificate (written to a `.pem` file in the box below the `Generate Verification Code` button. If all went well, you should now have a verified CA cert in your IoT Hub and setup is complete!


## Running the Demo

Running the demo is a lot more streightforward than the setup.

If you don't have the `azure-iot-device` python module installed, simply run the following:


```
$ pip install -r ./scripts/requirements.txt
```


We then need four environemnt variables set to run the client:


```
AZ_RESOURCE_GROUP_NAME=[name that you selected earlier]
AZ_DEVICE_UUID=[device uuid from earlier]
AZ_DEVICE_CERT_FILE=[the path to the device cert we generated earlier]
AZ_DEVICE_KEY_FILE=[the path to the device key (will probably be the same path as above)]
```


With these variables set, we can now run the messenger:

```
$ ./scripts/sendmsg.py
```


This script sends ten messages to the IoT Hub queue endpoint, which we can now peek at in Azure.

Starting from your Resource Group, navigate to the `IoTTrainingSBNamespace[rand]` Service Bus Namespace. Then go to the `Queues` submenu, and click on the `iottrainingsbqueue[rand]` queue. Finally, go to the Service Bus Explorer submenu and click on `Peek`.

Clicking on the `Peek` button in this page will allow you to view all 10 messages sent by the client, and if you click on them you can inspect their payloads and headers.

Demo complete!


## Teardown

Finally, there is a teardown script to ensure all of the demo artifacts are removed from azure.

Simply set the `AZ_RESOURCE_GROUP_NAME` environment variable to the name from before, and run the following:

```
./scripts/teardown.sh
```

This will delete everything created in this demo. Phew!
