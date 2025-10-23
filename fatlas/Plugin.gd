@tool extends EditorPlugin

var PREVIEW_GENERATOR_SCRIPT := preload("uid://cuhsx37y5k0n8")
var preview_generator : EditorResourcePreviewGenerator

var MAIN_SCENE := preload("uid://wgnllq4daibn")
var main : FatlasViewer

func _get_plugin_name() -> String:
	return "Fatlas Viewer"

func _get_plugin_icon() -> Texture2D:
	return preload("uid://ct3fuunjpwmsh")

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if main:
		main.visible = visible

func _handles(object: Object) -> bool:
	return object is CompositeTexture2D

func _edit(object: Object) -> void:
	if main == null: return

	main.edit(object)



func _enable_plugin() -> void:
	preview_generator = PREVIEW_GENERATOR_SCRIPT.new()
	# print(preview_generator)
	EditorInterface.get_resource_previewer().add_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.connect(_resources_reimported)

	_enter_tree()


func _disable_plugin() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.disconnect(_resources_reimported)

	_exit_tree()


func _enter_tree() -> void:
	if main != null: return

	main = MAIN_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main)
	_make_visible(false)


func _exit_tree() -> void:
	if main == null: return

	main.queue_free()
	main = null


func _resources_reimported(resources: PackedStringArray) -> void:
	for path in resources:
		if path.ends_with(".fat"):
			_fatlas_resource_reimported(path)


func _fatlas_resource_reimported(path: String) -> void:
	ResourceLoader.load(path, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)

