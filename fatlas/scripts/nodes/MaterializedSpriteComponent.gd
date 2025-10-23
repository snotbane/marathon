
## A single component copied from a [MaterializedSpriteTemplate]. Contains many [MaterializedSpriteElement]s (layers).
@tool class_name MaterializedSpriteComponent extends Node2D

const COMPONENT_KEYS = ["a", "e", "m", "n"]

const ROUGHMAT_MIX_MATERIAL := preload("uid://c70gd0pu5iw8p")
const ROUGHMAT_ADD_MATERIAL := preload("uid://rjp5m128v3st")

enum TextureComponent {
	ALBEDO,
	EMISSIVE,
	ROUGHMAT,
	NORMAL,
}


@export var mirrored : bool
@export var component : TextureComponent
@export var template : MaterializedSpriteTemplate

var texture_key : StringName :
	get:
		var mirrored_string : String = "l" if mirrored else "r"
		var component_string : String = COMPONENT_KEYS[component]
		return "-%s-%s" % [mirrored_string, component_string]


func _ready() -> void:
	if Engine.is_editor_hint() or self.get_child_count() > 0: return
	refresh()


func populate(__template: MaterializedSpriteTemplate, __mirrored: bool, __component: TextureComponent) -> void:
	template = __template
	mirrored = __mirrored
	component = __component

	# if component == TextureComponent.ALBEDO:
	# 	self.modulate = template.modulate
	# 	self.self_modulate = template.self_modulate

	refresh()


func refresh() -> void:
	for child in get_children():
		child.queue_free()
	transform = template.transform
	create_sprites_from_node(template)


func get_animated_sprite_current_texture(sprite: AnimatedSprite2D) -> Texture2D:
	return sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)


func create_sprites_from_node(node: Node2D) -> void:
	for child in node.get_children():
		if child is not Node2D: continue
		if child is AnimatedSprite2D:
			create_sprite_from_animated_sprite_2d(child)
		elif child is Sprite2D:
			create_sprite_from_sprite_2d(child)
		create_sprites_from_node(child)


func create_sprite_from_sprite_2d(sprite: Sprite2D) -> Sprite2D:
	var result := create_mesh(sprite, sprite.texture)

	if sprite.get_meta(&"roughmat_overhang", false) and component == TextureComponent.ROUGHMAT:
		var subsprite := create_mesh(sprite, sprite.texture)
		result.add_child(subsprite, false, INTERNAL_MODE_DISABLED)

		result.material = ROUGHMAT_MIX_MATERIAL
		subsprite.material = ROUGHMAT_ADD_MATERIAL

	self.add_child(result, false, InternalMode.INTERNAL_MODE_DISABLED)
	return result


func create_sprite_from_animated_sprite_2d(sprite: AnimatedSprite2D) -> Sprite2D:
	if not sprite.sprite_frames: return

	var result := create_mesh(sprite, get_animated_sprite_current_texture(sprite))

	if sprite.get_meta(&"roughmat_overhang", false) and component == TextureComponent.ROUGHMAT:
		var subsprite := create_mesh(sprite, get_animated_sprite_current_texture(sprite))
		result.add_child(subsprite, false, INTERNAL_MODE_DISABLED)

		result.material = ROUGHMAT_MIX_MATERIAL
		subsprite.material = ROUGHMAT_ADD_MATERIAL

	self.add_child(result, false, InternalMode.INTERNAL_MODE_DISABLED)
	return result


func create_mesh(node: Node2D, texture: Texture2D) -> Sprite2D:
	var result := MaterializedSpriteElement.new()
	result.populate(self, node)

	# result.set_script(ELEMENT_SCRIPT)
	result.texture = texture
	result.centered = node.centered
	result.name = node.name
	set_texture(result, texture)

	return result


func set_texture(node: Node2D, texture: Texture2D) -> void:
	node.texture = texture
	node.visible = node.texture != null
