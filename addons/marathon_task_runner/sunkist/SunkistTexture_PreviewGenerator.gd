@tool
extends EditorResourcePreviewGenerator

func _can_generate_small_preview() -> bool:
	return true


func _generate_small_preview_automatically() -> bool:
	return true


func _handles(type: String) -> bool:
	# print("CompositeTexture2DPreviewGenerator handles: ", type)
	return type == "SunkistTexture"


func _generate(resource: Resource, size: Vector2i, metadata: Dictionary) -> Texture2D:
	var image := (resource as SunkistTexture).map_default.get_image()
	image.resize(size.x, size.y, Image.Interpolation.INTERPOLATE_NEAREST)
	print("Generated a preview for SunkistTexture!")
	return ImageTexture.create_from_image(image)


func _generate_from_path(path: String, size: Vector2i, metadata: Dictionary) -> Texture2D:
	print("Generated a preview for SunkistTexture! (from path)")
	return null
