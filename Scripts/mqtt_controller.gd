# game_controller.gd
extends Node

const MQTTConfig = preload("res://Scripts/mqtt_config.gd")
const AnimationCancel = preload("res://Scripts/AnimationCancel.gd")
const AnimationLoop = preload("res://Scripts/AnimationLoop.gd")
const AnimationCount = preload("res://Scripts/AnimationCount.gd")
const AnimationController = preload("res://Scripts/AnimationController.gd")

# This variable will hold a reference to our MQTT client node.
@onready var mqtt_client = get_node("../MQTT_Client")

@export var animationController : AnimationController


var mqtt_config
var animation_loop_configs :Array
var animation_count_configs :Array
var animation_cancel_configs :Array


func _ready() -> void:
	#Get the mqtt config from the config loader
	var mqtt_config_loader = get_parent().get_node("ConfigLoader")
	if(mqtt_config_loader.start_loading == false):
		return
	mqtt_config = mqtt_config_loader.mqtt_config

	#get the animation configs from the config loader
	animation_loop_configs = mqtt_config_loader.animationLoopConfigs
	animation_count_configs = mqtt_config_loader.animationCountConfigs
	animation_cancel_configs = mqtt_config_loader.animationCancelConfigs

	
	# 1. Connect the signals from the MQTTClient node to our handler functions.
	#    This allows our controller to react to events from the client.
	mqtt_client.broker_connected.connect(_on_broker_connected)
	mqtt_client.broker_disconnected.connect(_on_broker_disconnected)
	mqtt_client.broker_connection_failed.connect(_on_broker_connection_failed)
	mqtt_client.received_message.connect(_on_message_received)

	#pass our settings to the client node before connecting.
	mqtt_client.client_id = mqtt_config.client_id
	mqtt_client.set_user_pass(str(mqtt_config.user), str(mqtt_config.password))
	
	#create broker URL
	var broker_url = ""
	
	if (mqtt_config.protocol == "mqtt"):
		broker_url = mqtt_config.ip + ":" + mqtt_config.port
	else:
		broker_url = mqtt_config.protocol + "://" + mqtt_config.ip + ":" + mqtt_config.port

	print("Attempting to connect to MQTT broker at:" + broker_url)
	
	#connect to broker
	mqtt_client.connect_to_broker(broker_url)


# This function is called when the client successfully connects.
func _on_broker_connected() -> void:
	print("Connected to MQTT broker!")
	
	#loop through our array and subscribe to each topic.
	_subscribe_topics()

func _subscribe_topics() -> void:
	var subscribe_set := {}
	
	#add unique cancel config subscribes
	for canceConfig in animation_cancel_configs:
		subscribe_set[canceConfig.subscribe] = true  # keys in a dictionary act like a set
	
	#add unique loop config subscribes
	for loopConfig in animation_loop_configs:
		subscribe_set[loopConfig.subscribe] = true  # keys in a dictionary act like a set
	
	#add unique count config subscribes
	for countConfig in animation_count_configs:
		subscribe_set[countConfig.subscribe] = true  # keys in a dictionary act like a set
	
	#turn dictionary back to array
	var unique_subscribes = subscribe_set.keys()
	
	#subscribe to topics
	for topic in unique_subscribes:
		print("   Subscribing to topic: '%s'" % topic)
		mqtt_client.subscribe(topic)
	

# This function handles incoming messages from any subscribed topic.
func _on_message_received(topic: String, message: String) -> void:
	print("Message Received!")
	print("   - Topic: %s" % topic)
	print("   - Payload: %s" % message)
	_handle_message(topic, message)


# This function is called if the connection fails.
func _on_broker_connection_failed() -> void:
	printerr("Failed to connect to MQTT broker.")


# This function is called if we get disconnected.
func _on_broker_disconnected() -> void:
	print("Disconnected from MQTT broker.")
	
	
func _handle_message(topic: String, message: String) -> void:
	#check wich animation conifg subscriped to the topic
	var relevant_subscriber = []
	
	#check cancel config
	for canceConfig in animation_cancel_configs:
		if(canceConfig.subscribe == topic):
			relevant_subscriber.append(canceConfig) # keys in a dictionary act like a set
	
	#check loop config
	for loopConfig in animation_loop_configs:
		if(loopConfig.subscribe == topic):
			relevant_subscriber.append(loopConfig) # keys in a dictionary act like a set
	
	#check count config
	for countConfig in animation_count_configs:
		if(countConfig.subscribe == topic):
			relevant_subscriber.append(countConfig) # keys in a dictionary act like a set
	
	#check which config has relevant payload 
	for animationConfig in relevant_subscriber:
		if animationConfig is AnimationCancel:
			if message.find(animationConfig.payload) != -1:
				animationController.cancel_animation(animationConfig)
				break

		elif animationConfig is AnimationLoop:
			if message.find(animationConfig.payload) != -1:
				animationController.start_loop_animation(animationConfig)
				break

		elif animationConfig is AnimationCount:
			if message.find(animationConfig.payload) != -1:
				animationController.start_count_animation(animationConfig)
				break
