@tool class_name ImagePreview extends Control

@onready var name_label : Label = $main/name_label
@onready var image_rect : TextureRect = $main/zoomable_image
@onready var path_label : Label = $main/path_label

var _label : String
@export var label : String :
	get: return _label
	set(value):
		_label = value

		if not name_label: return

		name_label.text = _label
		name_label.visible = not _label.is_empty()

@export var show_path : bool = true :
	get: return path_label.visible if path_label else true
	set(value):
		if not path_label: return
		path_label.visible = value


@export_storage var value : String :
	get: return path_label.text if path_label else ""
	set(val):
		if not path_label or value == val: return
		path_label.text = val

		refresh()
func set_value(val: String) -> void:
	value = val


var texture : Texture2D :
	get: return image_rect.texture
	set(value): image_rect.texture = value


func refresh() -> void:
	var file_exists := FileAccess.file_exists(value)

	visible = not value.is_empty()

	path_label.tooltip_text = value
	path_label.self_modulate = Color.WHITE if file_exists else Color.INDIAN_RED

	if not file_exists: texture = null; return

	var image := Image.new()
	var error := image.load(value)
	texture = ImageTexture.create_from_image(image) if error == OK else null


func clear() -> void:
	value = ""


func _ready() -> void:
	refresh()


func _on_path_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			OS.shell_open(ProjectSettings.globalize_path(value))
