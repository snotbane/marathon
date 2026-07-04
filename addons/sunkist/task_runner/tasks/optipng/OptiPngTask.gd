@tool
extends PythonTask

static func bytes_to_string(bytes: int) -> String:
	const SIZE_KB := 1024
	const SIZE_MB := SIZE_KB * 1024
	const SIZE_GB := SIZE_MB * 1024

	if bytes < SIZE_KB:
		return str(bytes) + " B"

	if bytes < SIZE_MB:
		return "%.2f KB" % (float(bytes) / SIZE_KB)

	if bytes < SIZE_GB:
		return "%.2f MB" % (float(bytes) / SIZE_MB)

	return "%.2f GB" % (float(bytes) / SIZE_GB)


@export var optipng_path: String:
	get:
		if not MarathonGlobalSettings.inst: return ""
		return MarathonGlobalSettings.inst.get_meta(&"optipng_path", "")
	set(value):
		if is_node_ready():
			MarathonGlobalSettings.inst.set_meta(&"optipng_path", value)
			MarathonGlobalSettings.inst.save_settings()

		validate_args()


var _target_dir: String
@export_global_dir var target_dir: String:
	get: return _target_dir
	set(value):
		if _target_dir == value: return

		refresh_comment_if_default()
		_target_dir = value
		validate_args()


var _bytes_reduced: int
var bytes_reduced: int:
	get: return _bytes_reduced
	set(value):
		if _bytes_reduced == value: return
		_bytes_reduced = value

		%bytes_reduced_label.text = "%s reduced" % [bytes_to_string(_bytes_reduced)]


func _get_python_script_path() -> String:
	return "res://addons/marathon_task_runner/task_runner/tasks/optipng/optipng.py"


func _get_default_comment() -> String:
	return MarathonUtils.get_project_preferred_path(target_dir)


func _validate_args() -> void:
	validate_file_path(optipng_path, true, "optipng_path")
	validate_dir_path(target_dir, true, "target_dir")


func _get_python_arguments() -> Array:
	return [
		optipng_path,
		target_dir,
	]


func _save_args(result: Dictionary) -> void:
	result.merge({
		&"optipng_path": optipng_path,
		&"target_dir": target_dir,
	})


func _load_args(data: Dictionary) -> void:
	target_dir = data[&"target_dir"]


func _reset() -> void:
	bytes_reduced = 0
	%image_preview.clear()


func _bus_poll() -> void:
	super._bus_poll()

	bytes_reduced = bus.get_value("output", "bytes", 0)
	%image_preview.value = bus.get_value("output", "image_preview", "")
