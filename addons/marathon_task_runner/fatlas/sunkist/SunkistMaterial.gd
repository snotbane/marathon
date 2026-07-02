@tool
class_name SunkistMaterial
extends ShaderMaterial

const SHADER: Shader = preload("res://addons/marathon_task_runner/fatlas/sunkist/shaders/Sunkist3D_Scissor.gdshader")


@export var unique_backface: bool = false:
	get: return get_shader_parameter(&"unique_backface")
	set(value):
		set_shader_parameter(&"unique_backface", value)
		emit_changed()


@export var emission_color: Color = Color.WHITE:
	get: return get_shader_parameter(&"emission_color")
	set(value):
		set_shader_parameter(&"emission_color", value)
		emit_changed()


@export_range(0.0, 1.0, 0.001) var ao_light_scale: float = 1.0:
	get: return get_shader_parameter(&"ao_light_scale")
	set(value):
		set_shader_parameter(&"ao_light_scale", value)
		emit_changed()


@export var ao_shadow_power: float = 4.0:
	get: return get_shader_parameter(&"ao_shadow_power")
	set(value):
		set_shader_parameter(&"ao_shadow_power", value)
		emit_changed()


@export_range(0.0, 1.0, 0.001) var roughness: float = 1.0:
	get: return get_shader_parameter(&"roughness")
	set(value):
		set_shader_parameter(&"roughness", value)
		emit_changed()


@export_range(0.0, 1.0, 0.001) var specular: float = 1.0:
	get: return get_shader_parameter(&"specular")
	set(value):
		set_shader_parameter(&"specular", value)
		emit_changed()


@export_range(0.0, 1.0, 0.001) var metallic: float = 1.0:
	get: return get_shader_parameter(&"metallic")
	set(value):
		set_shader_parameter(&"metallic", value)
		emit_changed()


@export_range(0.0, 1.0, 0.001) var normal_scale: float = 0.5:
	get: return get_shader_parameter(&"normal_scale")
	set(value):
		set_shader_parameter(&"normal_scale", value)
		emit_changed()


var composite_texture: CompositeTexture2D:
	set(value):
		composite_texture = value

		set_shader_component(&"_r_a")
		set_shader_component(&"_l_a")
		set_shader_component(&"_r_e")
		set_shader_component(&"_l_e")
		set_shader_component(&"_r_n")
		set_shader_component(&"_l_n")
		set_shader_component(&"_r_m")
		set_shader_component(&"_l_m")


func set_shader_component(key: StringName) -> void:
	var tex: Texture2D = composite_texture.get(&"map" + key)
	set_shader_parameter(key, tex)

	if tex is not AtlasTexture: return

	set_shader_parameter(key + &"_rect", Vector4(
		tex.region.position.x,
		tex.region.position.y,
		tex.region.size.x,
		tex.region.size.y
	))


func _init() -> void:
	shader = SHADER
