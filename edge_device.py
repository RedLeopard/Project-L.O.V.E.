import json
import random
import time
from datetime import datetime, timezone

LOCATION_ID = "STL-001"
DEVICE_ID = "LOVE-EDGE-01"

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

    print(json.dumps(telemetry, indent=2))

    time.sleep(5)
