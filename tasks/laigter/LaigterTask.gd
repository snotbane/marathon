
@tool extends PythonTask

## Path of the Laigter executable. See the Laigter documentation on how to install or where to find.
@export_global_file var laigter_path : String :
	get:
		if not MarathonGlobalSettings.inst: return ""
		return MarathonGlobalSettings.inst.get_meta(&"laigter_path", "")
	set(value):
		if not MarathonGlobalSettings.inst: return
		MarathonGlobalSettings.inst.set_meta(&"laigter_path", value)
		MarathonGlobalSettings.inst.save_settings()


var _preset_path : String
## Path of the Laigter preset file. This must be manually created in the Laigter app.
@export_global_file var preset_path : String :
	get: return _preset_path
	set(value):
		if _preset_path == value: return

		refresh_comment_if_default()
		_preset_path = value
		validate_args()


var _source_dir : String
## Source folder. All files in this folder and subfolders will be processed.
@export_global_dir var source_dir : String :
	get: return _source_dir
	set(value):
		if _source_dir == value: return

		refresh_comment_if_default()
		_source_dir = value
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


var _target_suffix : String = "_n"
## Suffix to append to the target file to distinguish it from the source.
@export var target_suffix : String = "_n" :
	get: return _target_suffix
	set(value):
		if _target_suffix == value: return

		refresh_comment_if_default()
		_target_suffix = value
		validate_args()


var _filter_include : String = ""
## Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.
@export var filter_include : String = "" :
	get: return _filter_include
	set(value):
		if _filter_include == value: return

		refresh_comment_if_default()
		_filter_include = value
		validate_args()


var _filter_exclude : String = ""
## Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.
@export var filter_exclude : String = "" :
	get: return _filter_exclude
	set(value):
		if _filter_exclude == value: return

		refresh_comment_if_default()
		_filter_exclude = value
		validate_args()


var _overwrite : bool = true
## If enabled, this will overwrite any target files that already exist. If disabled, this will NOT process any sources which already have a target file present at the specified [member target] and with the specified [member target_suffix].
@export var overwrite : bool = true :
	get: return _overwrite
	set(value):
		if _overwrite == value: return
		_overwrite = value

		refresh_comment_if_default()
		_overwrite = value
		validate_args()


@export_tool_button("Install Pillow to Venv") var _install_PIL := func() -> void:
	execute_static(MarathonGlobalSettings.inst.python_exe_path, ["-m", "pip", "install", "Pillow"])


func _get_default_comment() -> String:
	var result := "%s : %s >> %s" % [ _preset_path.get_file(), _source_dir.get_file(), _target_dir.get_file() ]

	if filter_include:
		result += " (include: %s)" % filter_include
	if filter_exclude:
		result += " (exclude: %s)" % filter_exclude

	return result


func _validate_args() -> void:
	validate_file_path(laigter_path, true, "laigter_path")
	validate_file_path(preset_path, true, "preset_path")
	validate_dir_path(source_dir, true, "source_dir")
	validate_dir_path(target_dir, false, "target_dir")
	validate_regex_string(filter_include, false, "filter_include")
	validate_regex_string(filter_exclude, false, "filter_exclude")


func _get_python_arguments() -> Array:
	return [
		laigter_path,
		preset_path,
		source_dir,
		target_dir if target_dir else source_dir,
		"/%s/" % target_suffix,
		"/%s/" % filter_include,
		"/%s/" % filter_exclude,
		overwrite,
	]


func _save_args(result: Dictionary) -> void:
	result.merge({
		&"laigter_path": laigter_path,
		&"preset_path": preset_path,
		&"source_dir": source_dir,
		&"target_dir": target_dir,
		&"target_suffix": target_suffix,
		&"filter_include": filter_include,
		&"filter_exclude": filter_exclude,
		&"overwrite": overwrite,
	})

func _load_args(data: Dictionary) -> void:
	preset_path = data[&"preset_path"]
	source_dir = data[&"source_dir"]
	target_dir = data[&"target_dir"]
	target_suffix = data[&"target_suffix"]
	filter_include = data[&"filter_include"]
	filter_exclude = data[&"filter_exclude"]
	overwrite = data[&"overwrite"]


func _reset() -> void:
	$v_box_container/content/split/source/preview.clear()
	$v_box_container/content/split/target/preview.clear()


func _bus_poll() -> void:
	super._bus_poll()

	$v_box_container/content/split/source/preview.value = bus.get_value("output", "source_preview", "")
	$v_box_container/content/split/target/preview.value = bus.get_value("output", "target_preview", "")

