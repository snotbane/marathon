
@tool extends PythonTask

var _target_dir : String
@export_global_dir var target_dir : String :
	get: return _target_dir
	set(value):
		if _target_dir == value: return

		refresh_comment_if_default()
		_target_dir = value

func _get_default_comment() -> String:
	return target_dir

