# mqtt_config.gd
class_name AnimationCount
extends RefCounted

var subscribe: String
var payload: String
var images_path: String
var default_image_path: String
var animation_duration: float
var animation_count: int

func _init(data: Dictionary = {}):
	subscribe = data.get("SUBSCRIBE", "")
	payload = data.get("PAYLOAD", "")
	images_path = data.get("IMAGES", "")
	default_image_path = data.get("DEFAULT-IMAGE", "")
	animation_duration = data.get("ANIMATION-DURATION", 0.0)
	animation_count = data.get("ANIMATION-COUNT", 1)
