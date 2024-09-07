shader_type spatial;

render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float projection_value = PROJECTION_MATRIX[2][2];
	ALBEDO = vec3(ceil(.2 / projection_value + .2) == 503. ? 1. : 0.);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
