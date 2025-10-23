
## A single sprite within a [Pixie].
@tool class_name PixieElement extends Sprite2D

var component : PixieComponent
var template : Node2D


func _ready() -> void:
	self.texture_changed.connect(_texture_changed)


func _template_visiblity_changed() -> void:
	self.visible = template.visible


func _texture_changed() -> void:
	self.z_index = template.z_index
	if self.texture is OffsetAtlasTexture:
		self.offset = self.texture.offset
		if Engine.is_editor_hint():
			template.offset = self.offset


func populate(__component: PixieComponent, __template: Node2D) -> void:
	component = __component
	template = __template

	template.visibility_changed.connect(_template_visiblity_changed)
	if template is Sprite2D:
		template.texture_changed.connect(refresh_sprite2d_from_texture)
		refresh_sprite2d_from_texture.call_deferred()
	elif template is AnimatedSprite2D:
		if not template.sprite_frames: return

		template.sprite_frames_changed.connect(refresh_animated_sprite2d_from_texture)
		template.animation_changed.connect(refresh_animated_sprite2d_from_texture)
		template.frame_changed.connect(refresh_animated_sprite2d_from_texture)
		refresh_animated_sprite2d_from_texture.call_deferred()
	_texture_changed()


func refresh_sprite2d_from_texture() -> void:
	if not template.texture: return
	self.texture = (template.texture as CompositeTexture2D).maps.get(component.texture_key)


func refresh_animated_sprite2d_from_texture() -> void:
	if not template.sprite_frames: return
	var tex : Texture2D = template.sprite_frames.get_frame_texture(template.animation, template.frame)
	self.texture = (tex as CompositeTexture2D).maps.get(component.texture_key) if tex else null
