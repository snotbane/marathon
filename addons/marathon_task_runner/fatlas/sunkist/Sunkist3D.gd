@tool
class_name Sunkist3D
extends Sprite3D

const OFFSET_FLIP := Vector2(1.0, -1.0)

static func get_sprite_offset(texture: CompositeTexture2D) -> Vector2:
	return texture.offset_default * OFFSET_FLIP - Vector2(0.0, texture.get_size().y) if texture else Vector2.ZERO


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


## If enabled, this Node's [member position.z] will be updated each frame to ensure it always remains in front/behind other [Node3D]s. In other words, [member position.z] becomes the layer depth of this sprite.
@export var keep_camera_depth: bool = false


@onready var _camera_depth: float = position.z

@onready var sunkist_parent: SunkistContainer3D = Sunkist3D.get_sunkist_ancestor(self)


var _was_editable := true


func _ready() -> void:
	if sunkist_parent:
		sunkist_parent.material_changed.connect(_refresh_material)
		sunkist_parent.size_changed.connect(_size_changed)
		centered = false

	if Engine.is_editor_hint() and material_override == null:
		material_override = SunkistMaterial.new()

	texture_changed.connect(_texture_changed)

	_refresh_material()


func _process(delta: float) -> void:
	if not keep_camera_depth: return

	var camera: Camera3D

	if Engine.is_editor_hint():
		if owner == get_tree().edited_scene_root or get_tree().edited_scene_root.is_editable_instance(owner):
			if _was_editable:
				position.z = _camera_depth
				_was_editable = false
			return
		else:
			_was_editable = true

		camera = EditorInterface.get_editor_viewport_3d().get_camera_3d()

	else:
		camera = get_viewport().get_camera_3d()

	position.z = camera.global_basis.z.dot(global_basis.z) * _camera_depth


func _refresh_material() -> void:
	if sunkist_parent and sunkist_parent.material_template:
		material_override = sunkist_parent.material_template.duplicate()

	_texture_changed()


func _texture_changed() -> void:
	material_override.composite_texture = texture
	_size_changed()


func _size_changed() -> void:
	if sunkist_parent:
		pixel_size = sunkist_parent.pixel_size

	if not centered:
		offset = Sunkist3D.get_sprite_offset(material_override.composite_texture)
