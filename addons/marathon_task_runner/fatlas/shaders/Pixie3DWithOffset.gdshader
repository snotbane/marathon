shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_toon, depth_prepass_alpha;

instance uniform vec4 modulate : source_color = vec4(1.0);

uniform bool unique_backface = true;

uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_strength = 1.0;

uniform float ao_shadow_power = 4.0;
uniform float ao_light_scale : hint_range(0.0, 1.0) = 0.667;

uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;

uniform float normal_scale : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D r_a : source_color;
uniform sampler2D l_a : source_color;
uniform sampler2D r_e : source_color, hint_default_black;
uniform sampler2D l_e : source_color, hint_default_black;
uniform sampler2D r_m : hint_default_black;
uniform sampler2D l_m : hint_default_black;
uniform sampler2D r_n : hint_normal;
uniform sampler2D l_n : hint_normal;
uniform vec2 r_a_offset;
uniform vec2 l_a_offset;
uniform vec2 r_e_offset;
uniform vec2 l_e_offset;
uniform vec2 r_m_offset;
uniform vec2 l_m_offset;
uniform vec2 r_n_offset;
uniform vec2 l_n_offset;
uniform vec2 r_a_size;
uniform vec2 l_a_size;
uniform vec2 r_e_size;
uniform vec2 l_e_size;
uniform vec2 r_m_size;
uniform vec2 l_m_size;
uniform vec2 r_n_size;
uniform vec2 l_n_size;

vec4 paper_swap(vec4 a, vec4 b, bool front_facing) {
	if (!front_facing && unique_backface) {
		return b;
	} else {
		return a;
	}
}

// void vertex() {
// 	// Called for every vertex the material is visible on.
// }

vec2 calc_uv(vec2 uv, vec2 size, vec2 offset) {
	vec2 result = uv * size + offset;
	if (result.x * result.y < 0.0 || result.x * result.y > 1.0) {
		return vec2(0);
	}
	return result;
}

void fragment() {
	vec2 r_a_uv = calc_uv(UV, r_a_size, r_a_offset);
	vec2 l_a_uv = calc_uv(UV, l_a_size, l_a_offset);
	vec4 paper_color = paper_swap(texture(r_a, r_a_uv), texture(l_a, l_a_uv), FRONT_FACING);
	ALBEDO = paper_color.rgb * modulate.rgb;
	ALPHA = paper_color.a * modulate.a;

	vec2 r_e_uv = calc_uv(UV, r_e_size, r_e_offset);
	vec2 l_e_uv = calc_uv(UV, l_e_size, l_e_offset);
	vec4 paper_emission = paper_swap(texture(r_e, r_e_uv), texture(l_e, l_e_uv), FRONT_FACING);
	EMISSION = paper_emission.rgb * paper_emission.a * emission_color.rgb * emission_strength;

	vec2 r_m_uv = calc_uv(UV, r_m_size, r_m_offset);
	vec2 l_m_uv = calc_uv(UV, l_m_size, l_m_offset);
	vec4 paper_matchannels = paper_swap(texture(r_m, r_m_uv), texture(l_m, l_m_uv), FRONT_FACING);
	ROUGHNESS = paper_matchannels.r * roughness;
	METALLIC = paper_matchannels.b * metallic;

	AO = pow(1.0 - paper_matchannels.g, ao_shadow_power);
	AO_LIGHT_AFFECT = ao_light_scale;

	vec2 r_n_uv = calc_uv(UV, r_n_size, r_n_offset);
	vec2 l_n_uv = calc_uv(UV, l_n_size, l_n_offset);
	vec4 paper_normal = paper_swap(texture(r_n, r_n_uv), texture(l_n, l_n_uv), FRONT_FACING);
	NORMAL_MAP = paper_normal.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
