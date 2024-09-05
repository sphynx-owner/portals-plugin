shader_type spatial;

render_mode unshaded;

uniform sampler2D viewport_texture;

uniform sampler2D outline_curve;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 portal_sample = texture(viewport_texture, SCREEN_UV);
	vec3 portal_sample_srgb = mix(
			pow((portal_sample.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
			portal_sample.rgb.rgb * (1.0 / 12.92),
			lessThan(portal_sample.rgb, vec3(0.04045)));
	
	vec2 centered_uv = UV - vec2(0.5);
	float further_uv = max(abs(centered_uv.x), abs(centered_uv.y)) * 2.;
	ALBEDO = portal_sample_srgb + texture(outline_curve, vec2(further_uv, 0)).xyz;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
