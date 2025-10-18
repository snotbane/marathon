@tool extends TextureRect

@onready var zoom_control : Control = $zoom_control
@onready var zoom_image : Sprite2D = $zoom_control/zoom_image

@export var sub_window_size := Vector2i(256, 256)
@export var expand_speed := 100.0
@export var focused_z_index : int = 10

var relative_mouse_position : Vector2i
var mouse_inside := false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		relative_mouse_position = event.position

func _process(delta: float) -> void:
	if not visible: return

	zoom_control.size = zoom_control.size.lerp(sub_window_size if mouse_inside else Vector2.ZERO, minf(expand_speed * delta, 1.0))

	var offset_center : Vector2i = zoom_control.size / 2
	zoom_control.position = Vector2i(relative_mouse_position) - offset_center
	zoom_image.texture = texture

	if not texture: return

	var offset_percent := Vector2(relative_mouse_position) / size
	zoom_image.position = -offset_percent * texture.get_size() + Vector2(offset_center)

func _on_mouse_entered() -> void:
	# zoom_control.visible = texture != null
	mouse_inside = true
	zoom_control.z_index = focused_z_index

func _on_mouse_exited() -> void:
	# zoom_control.hide()
	mouse_inside = false
	zoom_control.z_index = 0
