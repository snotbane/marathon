
@tool extends PythonTask

static var _optipng_path : String
@export_global_file var optipng_path : String :
	get: return _optipng_path
	set(value):
		if _optipng_path == value: return
		_optipng_path = value

var _target_dir : String
@export_global_dir var target_dir : String :
	get: return _target_dir
	set(value):
		if _target_dir == value: return

		refresh_comment_if_default()
		_target_dir = value

func _get_default_comment() -> String:
	return target_dir

