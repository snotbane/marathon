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

void fragment() {
	vec4 paper_color = paper_swap(texture(r_a, UV), texture(l_a, UV), FRONT_FACING);
	ALBEDO = paper_color.rgb * modulate.rgb;
	ALPHA = paper_color.a * modulate.a;

	vec4 paper_emission = paper_swap(texture(r_e, UV), texture(l_e, UV), FRONT_FACING);
	EMISSION = paper_emission.rgb * paper_emission.a * emission_color.rgb * emission_strength;

	vec4 paper_matchannels = paper_swap(texture(r_m, UV), texture(l_m, UV), FRONT_FACING);
	ROUGHNESS = paper_matchannels.r * roughness;
	METALLIC = paper_matchannels.b * metallic;

	AO = pow(1.0 - paper_matchannels.g, ao_shadow_power);
	AO_LIGHT_AFFECT = ao_light_scale;

	vec4 paper_normal = paper_swap(texture(r_n, UV), texture(l_n, UV), FRONT_FACING);
	NORMAL_MAP = paper_normal.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
