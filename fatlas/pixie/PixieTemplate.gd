## A collection of [Node2D]s that can be cloned to make up other components of a full image.
@tool class_name PixieTemplate extends Node2D

@export var size : Vector2i

@export_subgroup("Preview")

var preview : PixieComponent

var _preview_mirror : bool
## Shows what the sprite will look like when mirrored. No effect in game.
@export var preview_mirror : bool :
	get: return _preview_mirror
	set(value):
		_preview_mirror = value
		if preview == null: return
		preview.mirrored = _preview_mirror
		preview.refresh()
		_refresh_preview_visibility_here()


var _preview_component : PixieComponent.TextureComponent
## Shows what the sprite will look like with different components. No effect in game.
@export var preview_component : PixieComponent.TextureComponent :
	get: return _preview_component
	set(value):
		_preview_component = value
		if preview == null: return
		preview.component = _preview_component
		preview.refresh()
		_refresh_preview_visibility_here()
func _refresh_preview_visibility_here() -> void:
	# preview.visible = preview.mirrored or preview.component != PixieComponent.TextureComponent.ALBEDO
	preview.visible = not Engine.is_editor_hint() or preview.mirrored or preview.component != PixieComponent.TextureComponent.ALBEDO


func _ready() -> void:
	# if not Engine.is_editor_hint() or self != get_tree().edited_scene_root: return

	preview = PixieComponent.new()

	if Engine.is_editor_hint():
		self.add_child(preview, false, INTERNAL_MODE_BACK)
		preview.populate(self, _preview_mirror, _preview_component)
	else:
		self.add_sibling.call_deferred(preview, false)
		preview.populate(self, false, PixieComponent.TextureComponent.ALBEDO)

	_refresh_preview_visibility_here()
