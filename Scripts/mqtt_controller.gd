# game_controller.gd
extends Node

## --- Configuration ---
@export_group("Broker Connection")
@export var broker_ip: String = "broker.hivemq.com"
@export var broker_port: int = 1883

@export_group("Client Details")
@export var client_id: String = "godot_client_" + str(Time.get_unix_time_from_system())
@export var username: String = ""
@export var password: String = ""

@export_group("Subscriptions")
@export var topics_to_subscribe: Array[String] = ["godot/game/player_joined", "godot/game/score_updated"]

# This variable will hold a reference to our MQTT client node.
@onready var mqtt_client = get_node("../MQTT_Client")


func _ready() -> void:
    # 1. Connect the signals from the MQTTClient node to our handler functions.
    #    This allows our controller to react to events from the client.
    mqtt_client.broker_connected.connect(_on_broker_connected)
    mqtt_client.broker_disconnected.connect(_on_broker_disconnected)
    mqtt_client.broker_connection_failed.connect(_on_broker_connection_failed)
    mqtt_client.received_message.connect(_on_message_received)

    #pass our settings to the client node before connecting.
    mqtt_client.client_id = client_id
    if not username.is_empty():
        mqtt_client.set_user_pass(username, password)

    #create broker URL
    var broker_url = "ws://" + str(broker_ip) + ":" + str(broker_port)

    print("Attempting to connect to MQTT broker at %s" % broker_url)
    mqtt_client.connect_to_broker(broker_url)


# This function is called when the client successfully connects.
func _on_broker_connected() -> void:
    print("Connected to MQTT broker!")
    
    # Now that we are connected, loop through our array and subscribe to each topic.
    for topic in topics_to_subscribe:
        print("   Subscribing to topic: '%s'" % topic)
        mqtt_client.subscribe(topic)


# This function handles incoming messages from any subscribed topic.
func _on_message_received(topic: String, message: String) -> void:
    print("Message Received!")
    print("   - Topic: %s" % topic)
    print("   - Payload: %s" % message)


# This function is called if the connection fails.
func _on_broker_connection_failed() -> void:
    printerr("Failed to connect to MQTT broker.")


# This function is called if we get disconnected.
func _on_broker_disconnected() -> void:
    print("Disconnected from MQTT broker.")
