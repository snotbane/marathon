@tool
extends PythonTask

## If enabled, you will be able to compare files that were changed using this window. NOTE: Files will NOT be updated until you manually approve changes. If disabled, this will overwrite the original file(s). WARNING: You may lose data!
@export var review_changes: bool = true:
	set(value):
		if review_changes == value: return

		refresh_comment_if_default()
		review_changes = value
		validate_args()


## Target folder. All files processed will be placed in this folder, preserving any subfolders.
@export_global_dir var source_dir: String = "":
	set(value):
		if source_dir == value: return

		refresh_comment_if_default()
		source_dir = value
		validate_args()


## Target folder. All files processed will be placed in this folder, preserving any subfolders.
@export_global_dir var target_dir: String = "":
	set(value):
		if target_dir == value: return

		refresh_comment_if_default()
		target_dir = value
		validate_args()

var target_dir_safe: String:
	get: return target_dir if target_dir else source_dir


## Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.
@export var filter_include: String = r"":
	set(value):
		if filter_include == value: return

		refresh_comment_if_default()
		filter_include = value
		validate_args()


## Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.
@export var filter_exclude: String = r"":
	set(value):
		if filter_exclude == value: return

		refresh_comment_if_default()
		filter_exclude = value
		validate_args()


## Pixels with an opacity lower than this value will be discarded.
@export_range(0, 255, 1) var island_opacity: int = 0:
	set(value):
		if island_opacity == value: return

		refresh_comment_if_default()
		island_opacity = value
		validate_args()


## Pixel islands with a larger rectangular area than this will be included in the final image. Pixel islands with a smaller rectangular area than this will be discarded.
@export_range(0, 512, 1, "or_greater") var island_size: int = 256:
	set(value):
		if island_size == value: return

		refresh_comment_if_default()
		island_size = value
		validate_args()


func _get_python_script_path() -> String:
	return "res://addons/marathon_task_runner/task_runner/tasks/spruce/spruce.py"


func _get_default_comment() -> String:
	var result := "%s : %spx / %sa" % [
		target_dir_safe.get_file(),
		island_size,
		island_opacity,
	]

	if filter_include:
		result += " (include: %s)" % filter_include
	if filter_exclude:
		result += " (exclude: %s)" % filter_exclude

	return result


func _validate_args() -> void:
	validate_dir_path(source_dir, true, "source_dir")
	validate_dir_path(target_dir, false, "target_dir")
	validate_regex_string(filter_include, false, "filter_include")
	validate_regex_string(filter_exclude, false, "filter_exclude")


func _get_python_arguments() -> Array:
	return [
		Task.TEMP_DIR_PATH,
		source_dir,
		target_dir_safe,
		review_changes,
		"/%s/" % filter_include,
		"/%s/" % filter_exclude,
		island_opacity,
		island_size,
	]


func _save_args(result: Dictionary) -> void:
	result.merge({
		&"source_dir": source_dir,
		&"target_dir": target_dir,
		&"review_changes": review_changes,
		&"filter_include": filter_include,
		&"filter_exclude": filter_exclude,
		&"island_opacity": island_opacity,
		&"island_size": island_size,
	})


func _load_args(data: Dictionary) -> void:
		source_dir = data[&"source_dir"]
		target_dir = data[&"target_dir"]
		review_changes = data[&"review_changes"]
		filter_include = data[&"filter_include"]
		filter_exclude = data[&"filter_exclude"]
		island_opacity = data[&"island_opacity"]
		island_size = data[&"island_size"]


func _reset() -> void:
	%source_preview.clear()
	%target_preview.clear()
	%diff_preview.clear()


func _bus_poll() -> void:
	super._bus_poll()

	%source_preview.value = bus.get_value("output", "source_preview", "")
	%target_preview.value = bus.get_value("output", "target_preview", "")
	%diff_preview.value = bus.get_value("output", "target_bitmap", "")
