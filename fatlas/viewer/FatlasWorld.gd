
@tool extends Node3D

# @onready var mesh : Pixie3D = $root/quad
# @onready var sprite : Sprite2D = $root/quad/pixie_r_a/pixie/sprite
@onready var pixie : MeshInstance3D = $root/pixie

var _edited_resource : CompositeTexture2D
@export var edited_resource : CompositeTexture2D :
	get: return _edited_resource
	set(value):
		if _edited_resource == value: return
		_edited_resource = value

		if not _edited_resource or not pixie: return

		(pixie.mesh as QuadMesh).size = Vector2(
			minf(1.0, float(_edited_resource.default_map.get_size().x) / _edited_resource.default_map.get_size().y),
			minf(1.0, float(_edited_resource.default_map.get_size().y) / _edited_resource.default_map.get_size().x),
		)

		var material : ShaderMaterial = pixie.mesh.surface_get_material(0)
		for k in _edited_resource.maps:
			var param_texture := k.substr(1).replace_char("-".unicode_at(0), "_".unicode_at(0))
			if param_texture[2] == "e": continue

			var tex : OffsetAtlasTexture = _edited_resource.maps[k]
			var param_offset := param_texture + "_offset"
			var param_size := param_texture + "_size"
			material.set_shader_parameter(param_texture, tex)
			material.set_shader_parameter(param_offset, (tex.region.position / tex.atlas.get_size()))
			material.set_shader_parameter(param_size, _edited_resource.default_map.region.size / tex.atlas.get_size())


func edit(resource: CompositeTexture2D) -> void:
	edited_resource = resource

func _ready() -> void:
	pixie.mesh.surface_set_material(0, pixie.mesh.surface_get_material(0).duplicate())
