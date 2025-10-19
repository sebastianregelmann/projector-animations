# mqtt_config.gd
class_name MQTTConfig
extends RefCounted

var ip: String
var port: String
var client_id: String
var user: String
var password: String
var protocol : String

func _init(data: Dictionary = {}):
    ip = data.get("IP", "")
    port = data.get("PORT", "")
    client_id = data.get("CLIENT-ID", "")
    user = data.get("USER", "")
    password = data.get("PASSWORD", "")
    protocol = data.get("PROTOCOL", "")

