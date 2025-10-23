@tool extends EditorPlugin

var PREVIEW_GENERATOR_SCRIPT := preload("uid://cuhsx37y5k0n8")
var preview_generator : EditorResourcePreviewGenerator

func _enable_plugin() -> void:
	preview_generator = PREVIEW_GENERATOR_SCRIPT.new()
	# print(preview_generator)
	EditorInterface.get_resource_previewer().add_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.connect(_resources_reimported)


func _disable_plugin() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.disconnect(_resources_reimported)


func _resources_reimported(resources: PackedStringArray) -> void:
	for path in resources:
		if path.ends_with(".fat"):
			_fatlas_resource_reimported(path)


func _fatlas_resource_reimported(path: String) -> void:
	ResourceLoader.load(path, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)

