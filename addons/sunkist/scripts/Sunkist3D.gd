@tool
class_name Sunkist3D
extends Sprite3D

const OFFSET_FLIP := Vector2(1.0, -1.0)


static func get_sunkist_ancestor(node: Node) -> SunkistContainer3D:
	var result := node.get_parent()
	while result != null and result is not SunkistContainer3D:
		result = result.get_parent()
	return result


## If enabled, this will use a clone of an ancestor's [SunkistContainer3D.material_template].
@export var use_container_template: bool = true:
	set(value):
		use_container_template = value

		if sunkist_parent:
			if use_container_template and not sunkist_parent.material_changed.is_connected(_refresh_material):
				sunkist_parent.material_changed.connect(_refresh_material)
				_refresh_material()
			elif sunkist_parent.material_changed.is_connected(_refresh_material):
				sunkist_parent.material_changed.disconnect(_refresh_material)


## This will set an instance shader parameter which ensures the sprite will stay in its proper depth and helps prevent texture fighting, even when facing the opposite direction. Represented as an [int] value for simplicity, but actually translates to a [float] value. Elements which share the same [member popout_layer] are prone to texture fighting.
@export_range(-128, 128, 1, "or_greater", "or_less") var popout_layer: int = 0:
	get: return get_instance_shader_parameter(&"_popout_depth") * 10_000
	set(value): set_instance_shader_parameter(&"_popout_depth", 0.00_01 * value)


@onready var sunkist_parent: SunkistContainer3D = Sunkist3D.get_sunkist_ancestor(self)


var _was_editable := true


func _ready() -> void:
	if sunkist_parent:
		sunkist_parent.material_changed.connect(_refresh_material)
		sunkist_parent.size_changed.connect(_size_changed)
		# centered = false

	if Engine.is_editor_hint() and material_override == null:
		material_override = SunkistMaterial.new()

	texture_changed.connect(_texture_changed)

	_refresh_material()


func _refresh_material() -> void:
	if sunkist_parent and sunkist_parent.material_template:
		material_override = sunkist_parent.material_template.duplicate()

	_texture_changed()


func _texture_changed() -> void:
	material_override.texture = texture
	_size_changed()


func _size_changed() -> void:
	if sunkist_parent:
		pixel_size = sunkist_parent.pixel_size

	set_position_to_texture_offset(material_override.texture)


func set_position_to_texture_offset(texture: SunkistTexture) -> void:
	var flat: Vector2

	if texture:
		var texture_size := texture.get_size()
		flat = texture.offset_default * OFFSET_FLIP - Vector2(0.0, texture_size.y)
		if centered: flat += texture_size * 0.5
		flat *= pixel_size

	else: flat = Vector2.ZERO

	position = Vector3(
		flat.x,
		flat.y,
		position.z
	)
