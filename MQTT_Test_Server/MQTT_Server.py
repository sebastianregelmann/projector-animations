import asyncio
from amqtt.broker import Broker
from amqtt.client import MQTTClient
import logging

# Set up basic logging for broker output
formatter = "[%(asctime)s] :: %(levelname)s :: %(name)s :: %(message)s"
logging.basicConfig(level=logging.INFO, format=formatter)

BROKER_HOST = 'localhost'
BROKER_PORT = 1883
TOPIC = 'test/topic'

async def periodic_publisher():
    """
    Publishes a message every 10 seconds.
    """
    client = MQTTClient()
    await client.connect(f'mqtt://{BROKER_HOST}:{BROKER_PORT}/')
    count = 0
    try:
        while True:
            message = f"Hello MQTT {count}"
            await client.publish(TOPIC, message.encode())
            logging.info(f"Published message: {message} to topic: {TOPIC}")
            count += 1
            await asyncio.sleep(10)
    except asyncio.CancelledError:
        await client.disconnect()

async def run_server():
    """
    Initializes and runs the aMQTT broker.
    """
    broker_config = {
        'listeners': {
            'default': {
                'type': 'tcp',
                'bind': f'{BROKER_HOST}:{BROKER_PORT}'
            }
        },
        'sys_interval': 10,
        'auth': {
            'allow-anonymous': True
        }
    }

    broker = Broker(broker_config)
    try:
        # Start the broker
        await broker.start()
        logging.info(f"Broker running on {BROKER_HOST}:{BROKER_PORT}")

        # Start the periodic publisher in the background
        publisher_task = asyncio.create_task(periodic_publisher())

        # Keep the server running until it's stopped
        while True:
            await asyncio.sleep(1)
    except asyncio.CancelledError:
        # Gracefully shut down the broker
        await broker.shutdown()
        publisher_task.cancel()
        await publisher_task

def main():
    """
    Main function to run the broker.
    """
    try:
        asyncio.run(run_server())
    except KeyboardInterrupt:
        print("Server stopped by user.")

if __name__ == "__main__":
    main()
