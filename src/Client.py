import json
import time
import paho.mqtt.client as mqtt
from gpiozero import LED
from dataclasses import dataclass

CONFIG_PATH = "Config.json"
UNLOCK_ARRAY = "UNLOCK_MESSAGES"
LOCK_ARRAY = "LOCK_MESSAGES"


#Class to store information about MQTT messages
@dataclass
class MQTT_MESSAGE:
    TOPIC: str
    PAYLOAD: str
    
#Class to store information about MQTT messages
@dataclass
class MQTT_MESSAGE_CONFIG:
    TOPIC: str
    PAYLOAD: str
    PIN : int


# --- Methods for loading data from config json ---
def load_mqqt_config(path_config_file :str):
    # Load config file
    with open(path_config_file, "r") as f:
        config = json.load(f)

    # Access values
    mqtt = config["MQTT_Config"]

    IP = mqtt["IP"]
    PORT = mqtt["PORT"]
    PROTOCOL = "websockets" if mqtt["USE_WEBSOCKET"] else "tcp"
    USERNAME = mqtt["USERNAME"]
    PASSWORD = mqtt["PASSWORD"]
    
    return IP, PORT, PROTOCOL, USERNAME, PASSWORD


def load_mqtt_messages(path_config_file:str, message_array: str):
    # Load config file
    with open(path_config_file, "r") as f:
        config = json.load(f)
    
    # Access values
    data_array = config[message_array]    
    
    #create array of messages
    messages: list[MQTT_MESSAGE_CONFIG] = []

    for entry in data_array:
        msg = MQTT_MESSAGE_CONFIG(
            TOPIC=entry["TOPIC"],
            PAYLOAD=entry["PAYLOAD"],
            PIN = entry["PIN"]
        )
        messages.append(msg)

    return messages        


# --- MQTT Helper methods ---
def create_mqtt_client(IP, PORT, PROTOCOL, USERNAME, PASSWORD):
   # --- Create client ---
    client = mqtt.Client(transport=PROTOCOL)
    # Login with user and password
    client.username_pw_set(USERNAME, PASSWORD)
    
    #define event handler
    client.on_connect = on_connect
    client.on_message = on_message

    # --- Connect ---
    client.connect(IP, PORT) 

    return client


def subscribe_to_messages(messages):
    #only subscribe to unique topics
    unique_topics = {msg.TOPIC for msg in messages} 
    
    #subscribe to each unique topic
    for topic in unique_topics:
        client.subscribe(topic)
        print("Subscribed to", topic)

    
# --- MQTT Event Handlers ---
def on_connect(client, userdata, flags, rc, properties=None):
    print("Connected with result code:", rc)
    subscribe_to_messages(unlock_messages)
    subscribe_to_messages(lock_messages)

    
def on_message(client, userdata, msg):
    message = MQTT_MESSAGE(
            TOPIC=msg.topic,
            PAYLOAD=msg.payload.decode()
            )
    
    print(message)
    handle_incoming_message(message)


# --- MQTT Message Handling ---
def handle_incoming_message(message:MQTT_MESSAGE):
    #check if message topic and payload matches any of the registerd
    
    #check the unlock messages
    for message_to_check in unlock_messages:
        #check for topic
        if message_to_check.TOPIC == message.TOPIC:
            #check if payload contains matching string
            if message_to_check.PAYLOAD in message.PAYLOAD:
                unlock(message_to_check.PIN)
                return
            
    #check for locking messages
    for message_to_check in lock_messages:
        #check for topic
        if message_to_check.TOPIC == message.TOPIC:
            #check if payload contains matching string
            if message_to_check.PAYLOAD in message.PAYLOAD:
                lock(message_to_check.PIN)
                return


# --- Lock Handling ---
def unlock(pin : int):
    print("Unlocking Lock")
    pin_dictionary[pin].on()  # HIGH



def lock(pin: int):
    print("Locking Lock")
    pin_dictionary[pin].off()  # LOW



def get_unique_pins(unlock_messages, lock_messages):
    #Get all used pins from the config file
    all_messages = []
    for x in unlock_messages:
        all_messages.append(x)
    for x in lock_messages:
        all_messages.append(x)
    
    unique_pins = {msg.PIN for msg in all_messages}
    return unique_pins


def initialize_pins_gpio(unique_pins):
    pin_dictionary = {}
    for pin in unique_pins:
        pin_dictionary[pin] = LED(pin) 


    #set all on low (locked)
    for pin in unique_pins:
        pin_dictionary[pin].off()
    
    return pin_dictionary

#load config for MQTT
IP, PORT, PROTOCOL, USERNAME, PASSWORD = load_mqqt_config(CONFIG_PATH)

#create mqtt client
client = create_mqtt_client(IP, PORT, PROTOCOL, USERNAME, PASSWORD)

#load messages to subscribe to
unlock_messages = load_mqtt_messages(CONFIG_PATH,UNLOCK_ARRAY )
lock_messages = load_mqtt_messages(CONFIG_PATH, LOCK_ARRAY)


#load all unique pins from the config
uniqe_pins = get_unique_pins(unlock_messages, lock_messages)

#convert unique pins in dictionary (pin, GPIO)
pin_dictionary = initialize_pins_gpio(uniqe_pins)


#Start client background thread
client.loop_start()


# Keep running
try:
    while True:
        time.sleep(0.01)
except KeyboardInterrupt:
    print("Exiting...")
    client.loop_stop()
    # Release pin and close handle
    for pin in unique_pins:
        lgpio.gpio_release(h, pin)
        lgpio.gpiochip_close(h)
