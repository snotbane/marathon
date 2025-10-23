
@tool extends PythonTask


var _project_name : String
## Project name and also the name of the resulting image file(s) and data file.
@export var project_name : String :
	get: return _project_name
	set(value):
		if _project_name == value: return

		refresh_comment_if_default()
		_project_name = value
		validate_args()

var _source_dir : String
## Source folder to assemble target image(s) from.
@export_global_dir var source_dir : String :
	get: return _source_dir
	set(value):
		if _source_dir == value: return

		refresh_comment_if_default()
		_source_dir = value
		validate_args()

var _target_dir : String
## Target folder in which to place target image(s).
@export_global_dir var target_dir : String :
	get: return _target_dir
	set(value):
		if _target_dir == value: return

		refresh_comment_if_default()
		_target_dir = value
		validate_args()

var _target_size_limit : int = 65536
## The max pixel dimensions (square) a target image can be. If an island cannot be placed without expanding the target image beyond this limit, a new target image will be created.
@export_range(1, 65536, 1, "or_greater") var target_size_limit : int = 65536 :
	get: return _target_size_limit
	set(value):
		if _target_size_limit == value: return

		refresh_comment_if_default()
		_target_size_limit = value
		validate_args()

var _target_format := Image.Format.FORMAT_RGBA8
## Target image format. For now, only use RGBA.
@export_storage var target_format := Image.Format.FORMAT_RGBA8 :
	get: return _target_format
	set(value):
		if _target_format == value: return

		refresh_comment_if_default()
		_target_format = value
		validate_args()

var _data_format : int = 1
## File extension to write the data file to. This does not change the data itself; only the file extension. The result file can still be read as a .json file.
@export_enum("JSON", "FAT") var data_format : int = 1 :
	get: return _data_format
	set(value):
		if _data_format == value: return

		refresh_comment_if_default()
		_data_format = value
		validate_args()
var data_format_ext : String :
	get:
		match data_format:
			0:	return ".json"
			_:	return ".fat"

var _filter_include : String = r""
## Only file names (excluding extension) matching this regex filter will be added to the target image(s).
@export var filter_include : String = r"" :
	get: return _filter_include
	set(value):
		if _filter_include == value: return

		refresh_comment_if_default()
		_filter_include = value
		validate_args()

var _filter_exclude : String = r""
## Any file names (excluding extension) matching this regex filter will NOT be added to the target image(s).
@export var filter_exclude : String = r"" :
	get: return _filter_exclude
	set(value):
		if _filter_exclude == value: return

		refresh_comment_if_default()
		_filter_exclude = value
		validate_args()

var _filter_separate : String = r"^"
## File names (excluding extension) matching this regex filter will be separated into different images. Target files will be named based on this filter.
## This is primarily used to keep different kinds of images together, such as albedo and normal maps.
## For example, use "-[a-zA-Z]$" to separate files ending with an alphabetic character, like "-n", "-o", "-m", etc.
## Default: "^" (This will combine all images into a single superimage.)
## (".*" will separate all images individually, which is completely pointless.)
@export var filter_separate : String = r"^" :
	get: return _filter_separate
	set(value):
		if _filter_separate == value: return

		refresh_comment_if_default()
		_filter_separate = value
		validate_args()

var _filter_composite : String = r"((.+?)(?:_(\d+))?)_([lr])_(.)"
## Assigns composition data based on the internal groups of the regex. FOR NOW this only works with this specific pattern, so don't change this.
@export_storage var filter_composite : String = r"((.+?)(?:_(\d+))?)_([lr])_(.)" :
	get: return _filter_composite
	set(value):
		if _filter_composite == value: return

		refresh_comment_if_default()
		_filter_composite = value
		validate_args()

var _island_crop : bool = true
## If enabled, only the bounding box containing all visible pixels will be included.
## If disabled, include the entire source image.
@export var island_crop : bool = true :
	get: return _island_crop
	set(value):
		if _island_crop == value: return

		refresh_comment_if_default()
		_island_crop = value
		validate_args()

var _island_margin : int = 2
## The space between sprites and image bounds in the final image(s).
@export_range(0, 256, 1, "or_greater") var island_margin : int = 2 :
	get: return _island_margin
	set(value):
		if _island_margin == value: return

		refresh_comment_if_default()
		_island_margin = value
		validate_args()


@export_tool_button("Install Pillow to Venv") var _install_PIL := func() -> void:
	execute_static(MarathonGlobalSettings.inst.python_exe_path, ["-m", "pip", "install", "Pillow"])


func _get_python_script_path() -> String:
	return "res://addons/marathon/runner/tasks/fatlas/fatlas.py"


func _get_default_comment() -> String:
	return "%s%s : %s >> %s" % [
		project_name,
		data_format_ext,
		source_dir.get_file(),
		target_dir.get_file(),
	]


func _validate_args() -> void:
	validate_non_empty_string(project_name, "project_name")
	validate_dir_path(source_dir, true, "source_dir")
	validate_dir_path(target_dir, true, "target_dir")
	validate_dir_contains(source_dir, target_dir, false)
	validate_regex_string(filter_include, false, "filter_include")
	validate_regex_string(filter_exclude, false, "filter_exclude")
	validate_regex_string(filter_separate, false, "filter_separate")


func _get_python_arguments() -> Array:
	return [
		project_name,
		source_dir,
		target_dir,
		target_size_limit,
		"RGBA",
		data_format,
		"/%s/" % filter_include,
		"/%s/" % filter_exclude,
		"/%s/" % filter_separate,
		"/%s/" % filter_composite,
		island_crop,
		island_margin,
	]

func _save_args(result: Dictionary) -> void:
	result.merge({
		&"project_name": project_name,
		&"source_dir": source_dir,
		&"target_dir": target_dir,
		&"target_size_limit": target_size_limit,
		&"target_format": target_format,
		&"data_format": data_format,
		&"filter_include": filter_include,
		&"filter_exclude": filter_exclude,
		&"filter_separate": filter_separate,
		&"filter_composite": filter_composite,
		&"island_crop": island_crop,
		&"island_margin": island_margin,
	})

func _load_args(data: Dictionary) -> void:
	project_name = data[&"project_name"]
	source_dir = data[&"source_dir"]
	target_dir = data[&"target_dir"]
	target_size_limit = data[&"target_size_limit"]
	target_format = data[&"target_format"]
	data_format = data[&"data_format"]
	filter_include = data[&"filter_include"]
	filter_exclude = data[&"filter_exclude"]
	filter_separate = data[&"filter_separate"]
	filter_composite = data[&"filter_composite"]
	island_crop = data[&"island_crop"]
	island_margin = data[&"island_margin"]


func _finish(code: int) -> void:
	if status != SUCCEEDED: return

	for path in target_paths:
		var preview : ImagePreview = $v_box_container/content/previews/source.duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		preview.set_value.call_deferred(path)
		$v_box_container/content/previews/targets.add_child(preview)
	$v_box_container/content/previews/targets.columns = ceili(sqrt(target_paths.size()))
	$v_box_container/content/previews/targets.visible = true

func _reset() -> void:
	$v_box_container/content/previews/source.clear()
	$v_box_container/content/previews/source.visible = true

	for child in $v_box_container/content/previews/targets.get_children():
		child.queue_free()
	target_paths.clear()

var target_paths : PackedStringArray

func _bus_poll() -> void:
	super._bus_poll()

	$v_box_container/content/previews/source.value = bus.get_value("output", "source_preview", "")

	var target_updated : String = bus.get_value("output", "target_updated", "")

	if not target_updated.is_empty() and target_updated not in target_paths:
		target_paths.push_back(target_updated)

