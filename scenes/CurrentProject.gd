
@tool extends Label

signal nothing_saved
signal current_save_requested(path: String)

var file_path : String :
	get: return text
	set(value):
		if file_path == value: return
		text = value
		tooltip_text = text

		visible = not text.is_empty()
func set_file_path(path: String) -> void:
	file_path = path


func _on_save_current_pressed() -> void:
	if file_path.is_empty():
		nothing_saved.emit()
	else:
		current_save_requested.emit(file_path)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			OS.shell_open(ProjectSettings.globalize_path(file_path))