extends Node


@export var relativePathConfig = "res://Config/Config.json"

var configPath

func _enter_tree() -> void:

    configPath = ProjectSettings.globalize_path(relativePathConfig)
    print(configPath)

    pass
