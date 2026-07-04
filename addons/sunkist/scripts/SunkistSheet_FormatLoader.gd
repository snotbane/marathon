@tool
class_name SunkistSheet_FormatLoader
extends ResourceFormatLoader

func _handles_type(type: StringName) -> bool:
	return type == &"Resource"


func _get_recognized_extensions() -> PackedStringArray:
	return SunkistSheet.VALID_EXTENSIONS


func _get_resource_script_class(path: String) -> String:
	return "SunkistSheet"


func _get_resource_type(path: String) -> String:
	return "Resource"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var result := SunkistSheet.new()
		result.json_path = path

		if Engine.is_editor_hint():
			result.refresh_resources()

		return result
	else:
		printerr("Failed to load resource at path: ", path)
		return null
