# mqtt_config.gd
class_name AnimationCancel
extends RefCounted

var subscribe: String
var payload: String
var default_image_path: String

func _init(data: Dictionary = {}):
    subscribe = data.get("SUBSCRIBE", "")
    payload = data.get("PAYLOAD", "")
    default_image_path = data.get("DEFAULT-IMAGE", "")

