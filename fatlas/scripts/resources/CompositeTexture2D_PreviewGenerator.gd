@tool extends EditorResourcePreviewGenerator

func _can_generate_small_preview() -> bool:
	return true

func _generate_small_preview_automatically() -> bool:
	return true

func _handles(type: String) -> bool:
	# print("CompositeTexture2DPreviewGenerator handles: ", type)
	return type == "CompositeTexture2D"


func _generate(resource: Resource, size: Vector2i, metadata: Dictionary) -> Texture2D:
	var image := (resource as CompositeTexture2D).default_map.get_image()
	image.resize(size.x, size.y, Image.Interpolation.INTERPOLATE_NEAREST)
	print("Generated a preview for CompositeTexture2D!")
	return ImageTexture.create_from_image(image)

func _generate_from_path(path: String, size: Vector2i, metadata: Dictionary) -> Texture2D:
	print("Generated a preview for CompositeTexture2D! (from path)")
	return null


