
@tool class_name MarathonGlobalSettings extends Node

const CONFIG_PATH := "user://settings.cfg"

static var inst : MarathonGlobalSettings
static var config : ConfigFile

var install_venv_dialog : ConfirmationDialog

@export_global_dir var python_venv_path : String = "res://addons/marathon/.venv" :
	get: return get_meta(&"python_venv_path", "")
	set(value):
		if python_venv_path == value: return
		set_meta(&"python_venv_path", value)
		save_settings()
var python_exe_path : String :
	get: return ProjectSettings.globalize_path(python_venv_path.path_join("bin").path_join("python3"))

@export_tool_button("Install Python Venv") var install_venv_button := func() -> void:
	install_venv_dialog.dialog_text = "This will install a python virtual environment at:\n%s" % MarathonUtils.get_project_preferred_path(python_venv_path)
	if not python_venv_path.ends_with(".venv"): install_venv_dialog.dialog_text += "\nWarning! It is recommended that the destination folder is called \".venv\" !"
	install_venv_dialog.popup_centered()
func install_venv() -> void:
	PythonTask.execute_static("python3", ["-m", "venv", ProjectSettings.globalize_path(python_venv_path)])

@export_tool_button("Reveal Config File") var reveal_settings := func() -> void:
	OS.shell_open(ProjectSettings.globalize_path(CONFIG_PATH))


func _ready() -> void:
	if MarathonUtils.is_node_in_editor(self): return

	inst = self

	install_venv_dialog = ConfirmationDialog.new()
	install_venv_dialog.title = "Installing Python Virtual Environment"
	install_venv_dialog.confirmed.connect(install_venv)
	add_child(install_venv_dialog)

	if FileAccess.file_exists(CONFIG_PATH):
		load_settings()
	else:
		save_settings()

func load_settings() -> void:
	if not config: config = ConfigFile.new()

	config.load(CONFIG_PATH)

	for k in config.get_section_keys("default"):
		set_meta(StringName(k), config.get_value("default", k))

func save_settings() -> void:
	if not config: config = ConfigFile.new()

	for meta in get_meta_list():
		config.set_value("default", meta, get_meta(meta))

	config.save(CONFIG_PATH)

