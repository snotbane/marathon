@tool
class_name CompositeTexture2D
extends Texture2D

const DEFAULT_KEY := &"-r-a"


@export var maps: Dictionary[StringName, Texture2D]


var map_default: Texture2D:
	get: return maps[DEFAULT_KEY]


var map_r_a: Texture2D:
	get: return maps.get(&"-r-a")

var map_l_a: Texture2D:
	get: return maps.get(&"-l-a")

var map_r_e: Texture2D:
	get: return maps.get(&"-r-e")

var map_l_e: Texture2D:
	get: return maps.get(&"-l-e")

var map_r_n: Texture2D:
	get: return maps.get(&"-r-n")

var map_l_n: Texture2D:
	get: return maps.get(&"-l-n")

var map_r_m: Texture2D:
	get: return maps.get(&"-r-m")

var map_l_m: Texture2D:
	get: return maps.get(&"-l-m")


var offset_default: Vector2:
	get: return map_default.offset if map_default is OffsetAtlasTexture else Vector2.ZERO


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if not Engine.is_editor_hint(): return
	map_default.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if not Engine.is_editor_hint(): return
	map_default.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if not Engine.is_editor_hint(): return
	map_default.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return map_default.get_width()


func _get_height() -> int:
	return map_default.get_height()


# func _is_pixel_opaque(x: int, y: int) -> bool:
# 	return map_default.is_pixel_opaque(x, y)


func _has_alpha() -> bool:
	return map_default.has_alpha()
