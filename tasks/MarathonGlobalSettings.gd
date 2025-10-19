
@tool class_name MarathonGlobalSettings extends Node

const CONFIG_PATH := "user://settings.cfg"

static var inst : MarathonGlobalSettings
static var config : ConfigFile

var _python_path : String
@export_file var python_path : String = "res://addons/marathon/.venv/bin/python3" :
	get: return _python_path
	set(value):
		if _python_path == value: return
		_python_path = value

		config.set_value("default", "python_path", python_path)
		save_settings()
var python_path_global : String :
	get: return ProjectSettings.globalize_path(_python_path)

@export_tool_button("Reveal Config File") var reveal_tool_button := reveal_settings


func _ready() -> void:
	config = ConfigFile.new()

	if FileAccess.file_exists(CONFIG_PATH):
		load_settings()
	else:
		save_settings()

func load_settings() -> void:
	config.load(CONFIG_PATH)

func save_settings() -> void:
	config.save(CONFIG_PATH)

func reveal_settings() -> void:
	OS.shell_open(ProjectSettings.globalize_path(CONFIG_PATH))

