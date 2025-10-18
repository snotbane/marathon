@tool class_name ImagePreview extends Control

@onready var image_rect : TextureRect = $v_box_container/image
@onready var path_label : Label = $v_box_container/path_label

@export var show_path : bool = true :
	get: return path_label.visible if path_label else true
	set(value):
		if not path_label: return
		path_label.visible = value


@export var value : String :
	get: return path_label.text if path_label else ""
	set(val):
		if not path_label or value == val: return
		path_label.text = val
		path_label.tooltip_text = val

		refresh()
func set_value(val: String) -> void:
	value = val


var texture : Texture2D :
	get: return image_rect.texture
	set(value): image_rect.texture = value


func refresh() -> void:
	if not FileAccess.file_exists(value): texture = null; return

	var image := Image.new()
	var error := image.load(value)
	texture = ImageTexture.create_from_image(image) if error == OK else null


func clear() -> void:
	value = ""




func _on_image_mouse_entered() -> void:
	pass # Replace with function body.
