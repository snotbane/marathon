
@tool extends EditorPlugin

const MAIN_SCENE := preload("uid://ef5hvftp4smh")

var main : Control

func _get_plugin_name() -> String:
	return "Marathon"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("ProjectList", "EditorIcons")


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main:
		main.visible = visible


func _enable_plugin() -> void:
	# Add autoloads here.
	_enter_tree()



func _disable_plugin() -> void:
	# Remove autoloads here.
	_exit_tree()


func _enter_tree() -> void:
	# Initialization of the plugin goes here.

	main = MAIN_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main)
	_make_visible(false)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.

	if main:
		main.queue_free()
