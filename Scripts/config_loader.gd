extends Node
const MQTTConfig = preload("res://Scripts/mqtt_config.gd")
const AnimationCancel = preload("res://Scripts/AnimationCancel.gd")
const AnimationLoop = preload("res://Scripts/AnimationLoop.gd")
const AnimationCount = preload("res://Scripts/AnimationCount.gd")
const PathManager = preload("res://Scripts/PathManager.gd")


@export var pathManager : PathManager

var mqtt_config: MQTTConfig 
var animationCancelConfigs: Array = []
var animationLoopConfigs: Array = []
var animationCountConfigs: Array = []



func _enter_tree() -> void:
    var file = FileAccess.open(pathManager.get_config_path(), FileAccess.READ)
    if file:
        var json_text = file.get_as_text()
        var result = JSON.parse_string(json_text)

        #load mqtt config
        if typeof(result) == TYPE_DICTIONARY:
            var mqtt_data = result.get("MQTT-Config", {})
            mqtt_config = MQTTConfig.new(mqtt_data)  # <-- assign to member
            print("Loaded MQTT Config")
        else:
            push_error("Invalid JSON structure!")
        
        #load animatin cancel configs
        var cancel_array = result.get("MQTT-ANIMATION-CANCEL", [])
        if typeof(cancel_array) == TYPE_ARRAY:
            for item in cancel_array:
                var anim_cancel = AnimationCancel.new(item)
                animationCancelConfigs.append(anim_cancel)
            print("Loaded %d AnimationCancel configs" % animationCancelConfigs.size())
        else:
            push_error("MQTT-ANIMATION-CANCEL is not an array")

        #load animation loop config
        var loop_array = result.get("MQTT-ANIMATION-LOOP", [])
        if typeof(loop_array) == TYPE_ARRAY:
            for item in loop_array:
                var anim_loop = AnimationLoop.new(item)
                animationLoopConfigs.append(anim_loop)
            print("Loaded %d Animation Loop configs" % animationLoopConfigs.size())
        else:
            push_error("MQTT-ANIMATION-CANCEL is not an array")
        
        #load animation Count config
        var count_array = result.get("MQTT-ANIMATION-COUNT", [])
        if typeof(count_array) == TYPE_ARRAY:
            for item in count_array:
                var anim_count = AnimationCount.new(item)
                animationCountConfigs.append(anim_count)
            print("Loaded %d Animation Count configs" % animationCountConfigs.size())
        else:
            push_error("MQTT-ANIMATION-CANCEL is not an array")
