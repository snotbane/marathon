# Abstract base class for a node that uses [PixieComponent]s.
@tool class_name Pixie3D extends VisualInstance3D

enum ESizingMethod {
	## Modifies the size of the quad to match the size of the image * [member pixel_size].
	AUTO_PIXEL,
	## Modifies the size of the quad to fit inside a 1.0 x 1.0 space.
	AUTO_UNIT,
	## Allows the user to manually set the quad size.
	MANUAL,
}

const SHADER : Shader = preload("uid://cdufaegr5ju4f")

@onready var viewport : SubViewport = template.get_parent() if template else null

@export_tool_button("Refresh") var _refresh_button := func() -> void:
	refresh()

@export var parent_owner : Node

var _template : PixieTemplate
## Reference to the sprite component template.
@export var template : PixieTemplate :
	get: return _template
	set(value):
		if _template == value: return
		_template = value
		self._template_changed()
func _template_changed() -> void: pass

@export var auto_size := ESizingMethod.AUTO_PIXEL
var _pixel_size : float = 0.001
@export_range(0.0001, 1.0, 0.0001, "or_greater") var pixel_size : float = 0.001 :
	get: return _pixel_size
	set(value):
		if _pixel_size == value: return
		_pixel_size = value
		refresh_quad()

var _features : int
## Texture features for this visual instance.
@export_flags("Mirrored", "Emissive", "Roughness+", "Normal") var features : int :
	get: return _features
	set(value):
		if _features == value: return
		_features = value
		refresh()
var enable_mirrors : bool :
	get: return features & 1

var quad : QuadMesh
var material : Material :
	get: return quad.material if quad else null
	set(value):
		if quad.material == value: return
		quad.material = value


func _ready() -> void:
	refresh()


func refresh() -> void:
	refresh_quad()
	refresh_material()
	refresh_viewports()


func refresh_quad() -> void:
	if not quad:
		quad = QuadMesh.new()
		quad.resource_local_to_scene = true
	if not template: return
	match auto_size:
		ESizingMethod.AUTO_PIXEL:	quad.size = template.size * pixel_size
		ESizingMethod.AUTO_UNIT:	quad.size = Vector2(
			minf(1.0, float(template.size.x) / template.size.y),
			minf(1.0, float(template.size.y) / template.size.x),
		)
	print("template.size : %s" % [ template.size ])
	print("quad.size : %s" % [ quad.size ])


func refresh_material() -> void:
	if not material:
		material = ShaderMaterial.new()
		material.resource_local_to_scene = true
		material.shader = SHADER


func refresh_viewports() -> void:
	if not viewport: return
	for child in get_children():
		if child == viewport: continue
		remove_child(child)
		child.queue_free()

	viewport.size = template.size

	if material is ShaderMaterial:
		var vptexture := ViewportTexture.new()
		vptexture.viewport_path = parent_owner.get_path_to(viewport)
		material.set_shader_parameter(&"unique_backface", enable_mirrors)
		material.set_shader_parameter("r_a", vptexture)

	if enable_mirrors:
		create_subviewport_from_template(true, PixieComponent.TextureComponent.ALBEDO)
	else:
		remove_subviewport_from_template(true, PixieComponent.TextureComponent.ALBEDO)

	for i in 3:
		var i1 := i + 1
		if not features & (2 ** i1):
			remove_subviewport_from_template(false, i1)
			remove_subviewport_from_template(true, i1)
			continue
		create_subviewport_from_template(false, i1)
		if not enable_mirrors:
			remove_subviewport_from_template(true, i1)
			continue
		create_subviewport_from_template(true, i1)


func create_subviewport_from_template(mirrored : bool, component : PixieComponent.TextureComponent) -> SubViewport:
	var suffix := get_suffix(mirrored, component)

	var result : SubViewport = viewport.duplicate()
	result.name = "_" + viewport.name.substr(0, viewport.name.length() - suffix.length()) + suffix
	while result.get_child_count() > 0:
		result.remove_child(result.get_child(0))
	self.add_child(result)
	result.owner = parent_owner

	if self.material is ShaderMaterial:
		var vptexture := ViewportTexture.new()
		vptexture.viewport_path = parent_owner.get_path_to(result)
		self.material.set_shader_parameter(suffix.substr(1), vptexture)

	var comp := PixieComponent.new()
	comp.name = "_" + template.name + suffix
	comp.populate(template, mirrored, component)
	result.add_child(comp)
	comp.owner = parent_owner

	result.set_display_folded(true)

	return result


func remove_subviewport_from_template(mirrored: bool, component : PixieComponent.TextureComponent) -> void:
	var suffix := get_suffix(mirrored, component)

	if self.material is ShaderMaterial:
		self.material.set_shader_parameter(suffix.substr(1), null)


static func get_suffix(mirrored: bool, component : PixieComponent.TextureComponent) -> String:
	var result := "_l" if mirrored else "_r"
	match component:
		PixieComponent.TextureComponent.ALBEDO: 	result += "_a"
		PixieComponent.TextureComponent.EMISSIVE: 	result += "_e"
		PixieComponent.TextureComponent.ROUGHMAT:	result += "_m"
		PixieComponent.TextureComponent.NORMAL: 	result += "_n"
	return result
