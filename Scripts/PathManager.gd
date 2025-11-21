class_name PathManager
extends Node

var PATH_CONFIG := "Config/Config.json"

func get_config_path() -> String:
	var data_path : String

	if OS.has_feature("editor"):
		# When running inside the Godot editor
		data_path = ProjectSettings.globalize_path("res://" + PATH_CONFIG)
	else:
		# When running an exported build (.exe, Linux binary, etc.)
		var exe_dir = OS.get_executable_path().get_base_dir()
		data_path = exe_dir.path_join(PATH_CONFIG)

	return data_path


func get_image_path(relativePath :String) ->String:
	var data_path : String
	if OS.has_feature("editor"):
		# When running inside the Godot editor
		data_path = ProjectSettings.globalize_path("res://" + relativePath)
	else:
		# When running an exported build (.exe, Linux binary, etc.)
		var exe_dir = OS.get_executable_path().get_base_dir()
		data_path = exe_dir.path_join(relativePath)
	return data_path
