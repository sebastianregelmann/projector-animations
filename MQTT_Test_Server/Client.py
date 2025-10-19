import asyncio
import logging
import json
from amqtt.client import MQTTClient
from amqtt.errors import ClientError

# ======================
# MQTT CONNECTION CONFIG
# ======================
BROKER_HOST = "localhost"
BROKER_PORT = 9001
USERNAME = "user_3"
PASSWORD = "password_3"
PROTOCOL = "mqtt"  # Use 'mqtt' for TCP, 'ws' for WebSocket
MESSAGE_FILE = "Messages.json" 
PUBLISH_INTERVAL = 1  # seconds
# ======================

#local variables
messages = ""

# Setup logging
formatter = "[%(asctime)s] :: %(levelname)s :: %(name)s :: %(message)s"
logging.basicConfig(level=logging.INFO, format=formatter)



def load_messages():
    global messages
    with open(MESSAGE_FILE, "r") as f:
        data = json.load(f)
        messages = data.get("Messages", [])

async def mqtt_publisher():
    """
    Connects to the broker and publishes a message every 10 seconds.
    """
    client = MQTTClient()
    uri = f"{PROTOCOL}://{USERNAME}:{PASSWORD}@{BROKER_HOST}:{BROKER_PORT}"
    logging.info(f"Connecting to broker: {uri}")

    try:
        await client.connect(uri)
        logging.info("Connected to MQTT broker successfully.")

        count = 0
        while True:
            #load the message
            message = messages[count % len(messages)]["Message"]
            topic = messages[count % len(messages)]["Topic"]

            await client.publish(topic, message.encode())
            logging.info(f"Published message: {message}")
            count += 1
            await asyncio.sleep(PUBLISH_INTERVAL)

    except ClientError as e:
        logging.error(f"MQTT protocol error: {e}")
    except ConnectionError as e:
        logging.error(f"Connection failed: {e}")
    except asyncio.CancelledError:
        logging.info("Publisher task cancelled.")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
    finally:
        try:
            await client.disconnect()
            logging.info("Disconnected from broker.")
        except Exception:
            pass


def main():

    #load messages
    load_messages()

    try:
        asyncio.run(mqtt_publisher())
    except KeyboardInterrupt:
        print("Client stopped by user.")


if __name__ == "__main__":
    main()
