extends Node
const MQTTConfig = preload("res://Scripts/mqtt_config.gd")
const AnimationCancel = preload("res://Scripts/AnimationCancel.gd")
const AnimationLoop = preload("res://Scripts/AnimationLoop.gd")
const AnimationCount = preload("res://Scripts/AnimationCount.gd")
const PathManager = preload("res://Scripts/PathManager.gd")


@export var pathManager: PathManager

var start_loading : bool
var mqtt_config: MQTTConfig
var animationCancelConfigs: Array = []
var animationLoopConfigs: Array = []
var animationCountConfigs: Array = []


func _enter_tree() -> void:
	#check if the config file exists
	if _config_file_exists() == false:
		print("Config File is not at path: " + pathManager.get_config_path())
		#close app
		get_tree().quit()
		start_loading = false
		return

	var file = FileAccess.open(pathManager.get_config_path(), FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var result = JSON.parse_string(json_text)

		#load mqtt config
		if typeof(result) == TYPE_DICTIONARY:
			var mqtt_data = result.get("MQTT-Config", {})
			mqtt_config = MQTTConfig.new(mqtt_data) # <-- assign to member
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


	#check if all paths are valid
	if _missing_paths():
		#close application
		get_tree().quit()
		start_loading = false

	else:
		print("All Paths are valid")
		start_loading = true


func _config_file_exists() -> bool:
	var pathConfiFile = pathManager.get_config_path()
	return FileAccess.file_exists(pathConfiFile)


func _missing_paths() -> bool:
	#Loop over all paths and check if they exist
	var error_string: Array[String] = []

	#loop over cancel topics
	for cancel_topic in animationCancelConfigs:
		#check if path to cancel image folder exists
		if _image_folder_exists(cancel_topic.default_image_path) == false:
			error_string.append("Missing folder " + cancel_topic.default_image_path)
		else:
			#check if folder contains images
			if _image_folder_has_image(cancel_topic.default_image_path) == false:
				error_string.append("Missing images in " + cancel_topic.default_image_path)
	
	#loop over animationLoopConfigs
	for loop_topic in animationLoopConfigs:
		#check if path to animation folder exists
		if _image_folder_exists(loop_topic.images_path) == false:
			error_string.append("Missing folder " + loop_topic.images_path)
		else:
			#check if folder contains images
			if _image_folder_has_image(loop_topic.images_path) == false:
				error_string.append("Missing images in " + loop_topic.images_path)

	#loop over count animation configs
	for count_topic in animationCountConfigs:
		#check if path to animation folder exists
		if _image_folder_exists(count_topic.images_path) == false:
			error_string.append("Missing folder " + count_topic.images_path)
		else:
			#check if folder contains images
			if _image_folder_has_image(count_topic.images_path) == false:
				error_string.append("Missing images in " + count_topic.images_path)
		#check if path to default images existst
		if _image_folder_exists(count_topic.default_image_path) == false:
			error_string.append("Missing folder " + count_topic.default_image_path)
		else:
			#check if folder contains images
			if _image_folder_has_image(count_topic.default_image_path) == false:
				error_string.append("Missing images in " + count_topic.default_image_path)

	#print out all error messages
	for message in error_string:
		print(message)
	
	return len(error_string) > 0


func _image_folder_exists(folderpath: String) -> bool:
	var absolute_path = pathManager.get_image_path(folderpath)
	var d = DirAccess.open(absolute_path)
	return d != null


func _image_folder_has_image(folderpath: String) -> bool:
	var absolute_path = pathManager.get_image_path(folderpath)
	var dir = DirAccess.open(absolute_path)
	if dir == null:
		return false # folder doesn’t exist → no images

	dir.list_dir_begin()
	
	var count := 0
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir(): # ignores folders and only counts files
			count += 1
		file_name = dir.get_next()

	dir.list_dir_end()
	return count > 0
