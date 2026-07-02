shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;

instance uniform vec4 modulate : source_color = vec4(1.0);

uniform bool unique_backface = false;

uniform vec4 emission_color : source_color = vec4(1.0);
instance uniform float emission_strength = 1.0;

uniform float ao_shadow_power = 4.0;
uniform float ao_light_scale : hint_range(0.0, 1.0) = 1.0;

uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;

uniform float normal_scale : hint_range(0.0, 1.0) = 0.5;


uniform sampler2D _r_a : source_color;
uniform vec4 _r_a_rect;

uniform sampler2D _l_a : source_color;
uniform vec4 _l_a_rect;

uniform sampler2D _r_e : source_color, hint_default_black;
uniform vec4 _r_e_rect;

uniform sampler2D _l_e : source_color, hint_default_black;
uniform vec4 _l_e_rect;

uniform sampler2D _r_m : hint_default_black;
uniform vec4 _r_m_rect;

uniform sampler2D _l_m : hint_default_black;
uniform vec4 _l_m_rect;

uniform sampler2D _r_n : hint_normal;
uniform vec4 _r_n_rect;

uniform sampler2D _l_n : hint_normal;
uniform vec4 _l_n_rect;


vec4 atlas(vec2 uv, sampler2D tex, vec4 rect) {
	vec2 size = vec2(textureSize(tex, 0));
	rect = rect / vec4(size, size);
	return texture(tex, uv * rect.zw + rect.xy);
}


vec4 paper_swap(vec4 a, vec4 b, bool front_facing) {
	return (!front_facing && unique_backface) ? b : a;
}


void fragment() {
	vec4 paper_color = paper_swap(atlas(UV, _r_a, _r_a_rect), atlas(UV, _l_a, _l_a_rect), FRONT_FACING);
	ALBEDO = paper_color.rgb * modulate.rgb;
	ALPHA = paper_color.a * modulate.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;

	vec4 paper_emission = paper_swap(atlas(UV, _r_e, _r_e_rect), atlas(UV, _l_e, _l_e_rect), FRONT_FACING);
	EMISSION = paper_emission.rgb * paper_emission.a * emission_color.rgb * emission_strength;

	vec4 paper_custom = paper_swap(atlas(UV, _r_m, _r_m_rect), atlas(UV, _l_m, _l_m_rect), FRONT_FACING);
	ROUGHNESS = paper_custom.r * roughness;
	METALLIC = paper_custom.b * metallic;

	AO = pow(1.0 - paper_custom.g, ao_shadow_power);
	AO_LIGHT_AFFECT = ao_light_scale;

	vec4 paper_normal = paper_swap(atlas(UV, _r_n, _r_n_rect), atlas(UV, _l_n, _l_n_rect), FRONT_FACING);
	NORMAL_MAP = paper_normal.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}
