import json
import random
import time
from datetime import datetime, timezone

from awscrt import mqtt
from awsiot import mqtt_connection_builder


ENDPOINT = "a21bgn7b24qerd-ats.iot.us-east-1.amazonaws.com"
CLIENT_ID = "LOVE-EDGE-01"
TOPIC = "project-love/STL-001/telemetry"

CERT_PATH = "certs/device-certificate.pem.crt"
KEY_PATH = "certs/private.pem.key"
CA_PATH = "certs/AmazonRootCA1.pem"

LOCATION_ID = "STL-001"
DEVICE_ID = "LOVE-EDGE-01"


mqtt_connection = mqtt_connection_builder.mtls_from_path(
    endpoint=ENDPOINT,
    cert_filepath=CERT_PATH,
    pri_key_filepath=KEY_PATH,
    ca_filepath=CA_PATH,
    client_id=CLIENT_ID,
    clean_session=False,
    keep_alive_secs=30,
)

print("Connecting LOVE-EDGE-01 to AWS IoT Core...")

connect_future = mqtt_connection.connect()
connect_future.result()

print("Connected to AWS IoT Core.")


try:
    while True:
        telemetry = {
            "location_id": LOCATION_ID,
            "device_id": DEVICE_ID,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "status": "ONLINE",
            "temperature_f": random.randint(68, 78),
            "cpu_percent": random.randint(10, 45),
            "network": "CONNECTED"
        }

        message = json.dumps(telemetry)

        mqtt_connection.publish(
            topic=TOPIC,
            payload=message,
            qos=mqtt.QoS.AT_LEAST_ONCE
        )

        print("Published:")
        print(json.dumps(telemetry, indent=2))

        time.sleep(5)

except KeyboardInterrupt:
    print("\nStopping Project L.O.V.E.")

finally:
    disconnect_future = mqtt_connection.disconnect()
    disconnect_future.result()
