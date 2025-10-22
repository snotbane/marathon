
@tool extends PythonTask

var _review_changes : bool = true
## If enabled, you will be able to compare files that were changed using this window. NOTE: Files will NOT be updated until you manually approve changes.
# If disabled, this will overwrite the original file(s). WARNING: You may lose data!
@export var review_changes : bool = true :
	get: return _review_changes
	set(value):
		if _review_changes == value: return

		refresh_comment_if_default()
		_review_changes = value
		validate_args()


var _target_dir : String
## Target folder. All files processed will be placed in this folder, preserving any subfolders. Leave blank to use [member source_dir].
@export_global_dir var target_dir : String = "" :
	get: return _target_dir
	set(value):
		if _target_dir == value: return

		refresh_comment_if_default()
		_target_dir = value
		validate_args()


var _filter_include : String = r""
## Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.
@export var filter_include : String = r"" :
	get: return _filter_include
	set(value):
		if _filter_include == value: return

		refresh_comment_if_default()
		_filter_include = value
		validate_args()


var _filter_exclude : String = r""
## Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.
@export var filter_exclude : String = r"" :
	get: return _filter_exclude
	set(value):
		if _filter_exclude == value: return

		refresh_comment_if_default()
		_filter_exclude = value
		validate_args()


var _island_opacity : int = 0
## Pixels with an opacity lower than this value will be discarded.
@export_range(0, 255, 1) var island_opacity : int = 0 :
	get: return _island_opacity
	set(value):
		if _island_opacity == value: return

		refresh_comment_if_default()
		_island_opacity = value
		validate_args()


var _island_size : int = 256
## Pixel islands with a larger rectangular area than this will be included in the final image. Pixel islands with a smaller rectangular area than this will be discarded.
@export_range(0, 512, 1, "or_greater") var island_size : int = 256 :
	get: return _island_size
	set(value):
		if _island_size == value: return

		refresh_comment_if_default()
		_island_size = value
		validate_args()


func _get_python_script_path() -> String:
	return "res://addons/marathon/tasks/spruce/spruce.py"

func _get_default_comment() -> String:
	var result := "%s : %spx / %sa" % [
		target_dir.get_file(),
		island_size,
		island_opacity,
	]

	if filter_include:
		result += " (include: %s)" % filter_include
	if filter_exclude:
		result += " (exclude: %s)" % filter_exclude

	return result

func _validate_args() -> void:
	validate_dir_path(target_dir, true, "target_dir")
	validate_regex_string(filter_include, false, "filter_include")
	validate_regex_string(filter_exclude, false, "filter_exclude")


func _get_python_arguments() -> Array:
	return [
		Task.TEMP_DIR_PATH,
		target_dir,
		review_changes,
		"/%s/" % filter_include,
		"/%s/" % filter_exclude,
		island_opacity,
		island_size,
	]

func _save_args(result: Dictionary) -> void:
	result.merge({
		&"target_dir": target_dir,
		&"review_changes": review_changes,
		&"filter_include": filter_include,
		&"filter_exclude": filter_exclude,
		&"island_opacity": island_opacity,
		&"island_size": island_size,
	})

func _load_args(data: Dictionary) -> void:
		target_dir = data[&"target_dir"]
		review_changes = data[&"review_changes"]
		filter_include = data[&"filter_include"]
		filter_exclude = data[&"filter_exclude"]
		island_opacity = data[&"island_opacity"]
		island_size = data[&"island_size"]


func _reset() -> void:
	$v_box_container/content/split/compare/source/preview.clear()
	$v_box_container/content/split/compare/target/preview.clear()
	$v_box_container/content/split/review/diff/preview.clear()


func _bus_poll() -> void:
	super._bus_poll()

	$v_box_container/content/split/compare/source/preview.value = bus.get_value("output", "source_preview", "")
	$v_box_container/content/split/compare/target/preview.value = bus.get_value("output", "target_preview", "")
	$v_box_container/content/split/review/diff/preview.value = bus.get_value("output", "target_bitmap", "")

