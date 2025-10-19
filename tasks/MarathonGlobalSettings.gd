
@tool class_name MarathonGlobalSettings extends Node

const CONFIG_PATH := "user://settings.cfg"

static var inst : MarathonGlobalSettings
static var config : ConfigFile

@export_file var python_path : String = "res://addons/marathon/.venv/bin/python3" :
	get: return get_meta(&"python_path", "")
	set(value):
		if python_path == value: return
		set_meta(&"python_path", value)
		save_settings()
var python_path_global : String :
	get: return ProjectSettings.globalize_path(python_path)

@export_tool_button("Reveal Config File") var reveal_tool_button := reveal_settings


func _ready() -> void:
	inst = self
	config = ConfigFile.new()

	if FileAccess.file_exists(CONFIG_PATH):
		load_settings()
	else:
		save_settings()

func load_settings() -> void:
	config.load(CONFIG_PATH)

	for k in config.get_section_keys("default"):
		set_meta(StringName(k), config.get_value("default", k))

func save_settings() -> void:
	for meta in get_meta_list():
		config.set_value("default", meta, get_meta(meta))

	config.save(CONFIG_PATH)

func reveal_settings() -> void:
	OS.shell_open(ProjectSettings.globalize_path(CONFIG_PATH))

