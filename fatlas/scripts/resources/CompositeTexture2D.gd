@tool class_name CompositeTexture2D extends Texture2D

@export var maps : Dictionary[StringName, Texture2D]

const DEFAULT_KEY := "-r-a"

var default_map : Texture2D :
	get: return maps[DEFAULT_KEY]

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if not Engine.is_editor_hint(): return
	default_map.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if not Engine.is_editor_hint(): return
	default_map.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if not Engine.is_editor_hint(): return
	default_map.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return default_map.get_width()


func _get_height() -> int:
	return default_map.get_height()


# func _is_pixel_opaque(x: int, y: int) -> bool:
# 	return default_map.is_pixel_opaque(x, y)


func _has_alpha() -> bool:
	return default_map.has_alpha()
