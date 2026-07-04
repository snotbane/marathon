@tool
class_name FatsheetViewer
extends Control

const IMAGE_PREVIEW_SCENE: PackedScene = preload("uid://3djnsrgpqbb1")


signal edited(resource: SunkistTexture)


@onready var grid: GridContainer = $split/composite/grid


@export_storage var resource: SunkistTexture


func edit(__resource__: Object) -> void:
	if __resource__ is not SunkistTexture:
		return

	resource = __resource__

	for child in grid.get_children():
		child.queue_free()

	for k in resource.maps:
		var texture := resource.maps[k]

		var image_preview: ImagePreview = IMAGE_PREVIEW_SCENE.instantiate()
		grid.add_child(image_preview)
		image_preview.path_mode = 1
		image_preview.path_text = k
		image_preview.texture = texture
		image_preview.visible = true

	for child: ImagePreview in grid.get_children():
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
		order += resource.maps.size()
		grid.move_child(child, order)

	edited.emit(resource)
