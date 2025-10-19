# mqtt_config.gd
class_name AnimationLoop
extends RefCounted

var subscribe: String
var payload: String
var images_path: String
var animation_duration: float

func _init(data: Dictionary = {}):
    subscribe = data.get("SUBSCRIBE", "")
    payload = data.get("PAYLOAD", "")
    images_path = data.get("IMAGES", "")
    animation_duration = data.get("ANIMATION-DURATION", 0.0)

