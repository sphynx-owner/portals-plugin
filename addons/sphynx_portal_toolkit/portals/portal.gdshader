shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D viewport_texture;

uniform sampler2D inner_textures[10];
uniform int viewport_indexes[10];

uniform float show_debug;

uniform vec4 debug_color : source_color;

uniform sampler2D outline_curve;

varying vec3 vertex_pos;

void vertex() {
	vec4 tl_position = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(1, -1, 1, 1);
	tl_position.xyz /= tl_position.w;
	vec4 tr_position = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(-1, -1, 1, 1);
	tr_position.xyz /= tr_position.w;
	vec4 bl_position = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(1, 1, 1, 1);
	bl_position.xyz /= bl_position.w;
	vec4 br_position = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(-1, -1, 1, 1);
	br_position.xyz /= br_position.w;
	vec3 model_world_position = vec3(MODEL_MATRIX[3][0], MODEL_MATRIX[3][1], MODEL_MATRIX[3][2]);
	vec3 camera_offset = CAMERA_POSITION_WORLD - model_world_position;
	vec3 forward_vector = normalize(MODEL_NORMAL_MATRIX * vec3(0, 0, 1));
	forward_vector *= step(0, dot(forward_vector, camera_offset)) * 2. - 1.;
	vec3 tl_offset = tl_position.xyz - model_world_position;
	vec3 tr_offset = tr_position.xyz - model_world_position;
	vec3 bl_offset = bl_position.xyz - model_world_position;
	vec3 br_offset = br_position.xyz - model_world_position;
	float max_forward_offset = min(0, min(dot(tl_offset, forward_vector), min(dot(tr_offset, forward_vector), min(dot(bl_offset, forward_vector), dot(br_offset, forward_vector)))));
	vertex_pos = vec4(MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz + forward_vector * max_forward_offset;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(vertex_pos, 1.0);
	//vertex_pos = tl_position.xyz;// tl_position.xyz;
}

void fragment() {
	vec4 portal_sample = texture(viewport_texture, SCREEN_UV);
	int inner_texture_id = 0;
	
	while(inner_texture_id < 10 && portal_sample.rgb == vec3(0, 1, 0)) {
		portal_sample = texture(inner_textures[inner_texture_id], SCREEN_UV);
		inner_texture_id++;
	}
	if(portal_sample.rgb == vec3(0, 1, 0)) {
		portal_sample = vec4(0, 0, 0, 1);
	}
	
	vec3 portal_sample_srgb = mix(
		pow((portal_sample.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
		portal_sample.rgb.rgb * (1.0 / 12.92),
		lessThan(portal_sample.rgb, vec3(0.04045)));
	
	vec2 centered_uv = UV - vec2(0.5);
	float further_uv = max(abs(centered_uv.x), abs(centered_uv.y)) * 2.;
	ALBEDO = portal_sample_srgb + debug_color.xyz / 3. * show_debug;//+ texture(outline_curve, vec2(further_uv, 0)).xyz;//vertex_pos;//
}
