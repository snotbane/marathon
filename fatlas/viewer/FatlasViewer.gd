
@tool class_name FatlasViewer extends Control

const IMAGE_PREVIEW_SCENE : PackedScene = preload("uid://3djnsrgpqbb1")

@onready var grid : GridContainer = $split/composite/grid
@onready var pixie : Pixie3D = $split/preview/sub_viewport_container/sub_viewport/root/quad
@onready var pixie_viewport : SubViewport = $split/preview/sub_viewport_container/sub_viewport/root/quad/pixie_r_a
@onready var sprite : Sprite2D = pixie.template.get_child(0)

@export_storage var resource : CompositeTexture2D

func _ready() -> void:
	pixie.parent_owner = self

func edit(__resource__: Object) -> void:
	if __resource__ is not CompositeTexture2D:
		return

	# if resource == __resource__: return
	resource = __resource__

	for child in grid.get_children():
		child.queue_free()

	for k in resource.maps:
		var texture := resource.maps[k]

		var image_preview : ImagePreview = IMAGE_PREVIEW_SCENE.instantiate()
		grid.add_child(image_preview)
		image_preview.path_mode = ImagePreview.MANUAL
		image_preview.path_text = k
		image_preview.texture = texture
		image_preview.visible = true

	for child : ImagePreview in grid.get_children():
		var order := 0
		match child.path_text:
			"-r-n": order = -1
			"-l-n": order = -2
			"-r-m": order = -3
			"-l-m": order = -4
			"-r-e": order = -5
			"-l-e": order = -6
			"-r-a": order = -7
			"-l-a": order = -8
		order += grid.get_child_count()
		grid.move_child(child, order)


	sprite.texture = resource
	pixie.template.size = sprite.texture.get_size()
	pixie.refresh()
	sprite.set.call_deferred(&"offset", Vector2.ZERO)
	print_tree_pretty()
	print("pixie.template.size : %s" % [ pixie.template.size ])


func _process(delta: float) -> void:
	# if sprite:
	# 	sprite.offset.x = sin(Time.get_ticks_msec() / 1000.0) * 1000.0
	# 	print("sprite.offset : %s" % [ sprite.offset ])
	pass
