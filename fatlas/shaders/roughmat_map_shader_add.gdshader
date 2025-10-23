shader_type canvas_item;
render_mode blend_add, unshaded;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a >= 1.0) {
		tex.a = 0.0;
	}
	COLOR = tex;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
