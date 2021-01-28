#!/usr/bin/env python3
import os
import uuid
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import Message, X509
import asyncio
messages_to_send = 10


async def main():
    hostname = (os.getenv("AZ_RESOURCE_GROUP_NAME").strip() +
                "-IotHub.azure-devices.net")
    device_id = os.getenv("AZ_DEVICE_UUID").strip()

    x509 = X509(
        cert_file=os.getenv("AZ_DEVICE_CERT_FILE"),
        key_file=os.getenv("AZ_DEVICE_KEY_FILE"),
    )
    # The client object is used to interact with your Azure IoT hub.
    device_client = IoTHubDeviceClient.create_from_x509_certificate(
        hostname=hostname, device_id=device_id, x509=x509
    )
    # Connect the client.
    await device_client.connect()

    async def send_test_message(i):
        print("sending message #" + str(i))
        msg = Message("buying " + str(i) + " bitcoin ah ah ah")
        msg.message_id = uuid.uuid4()
        msg.correlation_id = "correlation-1234"
        msg.custom_properties["IMPERATIVE"] = "BUY BITCOIN"
        msg.custom_properties["level"] = "queue"
        await device_client.send_message(msg)
        print("done sending message #" + str(i))

    # send `messages_to_send` messages in parallel
    await asyncio.gather(*[send_test_message(i) for i in range(1, messages_to_send + 1)])
    # finally, disconnect
    await device_client.disconnect()

if __name__ == "__main__":
    envs = ["AZ_RESOURCE_GROUP_NAME",
            "AZ_DEVICE_UUID",
            "AZ_DEVICE_CERT_FILE",
            "AZ_DEVICE_KEY_FILE"]

    for envvar in envs:
        if os.getenv(envvar) is None:
            print(f"please set {envvar}. exiting...")
            exit(1)

    asyncio.run(main())
    # If using Python 3.6 or below, use the following code instead of asyncio.run(main()):
    # loop = asyncio.get_event_loop()
    # loop.run_until_complete(main())
    # loop.close()
