shader_type spatial;

render_mode cull_disabled, blend_mix, diffuse_burley, specular_schlick_ggx, world_vertex_coords, depth_test_disabled, skip_vertex_transform, unshaded, depth_draw_always;

// MIT License. Made by Leo Peltola
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform sampler2D texture_noise : source_color, filter_linear, repeat_enable;
uniform sampler2D texture_lines : source_color, filter_linear, repeat_enable;
uniform sampler2D texture_grain : source_color, filter_linear, repeat_enable;
uniform bool color_passthrough = false;
uniform bool depth_check = true;
uniform bool normal_check = true;
uniform vec3 tint_color : source_color = vec3(1.0);
uniform vec3 line_color : source_color = vec3(0.0);
uniform float depth_line_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float normal_line_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float noise_offset_multiplier : hint_range(0.0, 2.0) = 0.5;
uniform float red_weight : hint_range(0.0, 2.0) = 0.5;
uniform float green_weight : hint_range(0.0, 2.0) = 0.5;
uniform float blue_weight : hint_range(0.0, 2.0) = 0.5;
uniform float black_threshold : hint_range(0.0, 2.0, 0.001) = 0.001;
uniform float white_threshold : hint_range(0.0, 2.0, 0.001) = 2.0;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.2;
uniform float line_size : hint_range(0.0, 2.0) = 1.0;
uniform float lines_texture_scale : hint_range(0.0, 10.0) = 5.0;
uniform float grain_texture_scale : hint_range(0.0, 10.0) = 10.0;

float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	float raw_depth = texture(depth_texture, screen_uv)[0];
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	view_space.xyz /= view_space.w;
	return -view_space.z;
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal, float depth_diff){
	// Credit: https://threejs.org/examples/webgl_postprocessing_pixel.html
	float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
	float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
	float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(baseNormal, newNormal)) * depthIndicator * normalIndicator;
}

void vertex(){
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 pixel_size = vec2(1.0 / VIEWPORT_SIZE.xy) * line_size;
	vec4 noise_tex = texture(texture_noise, SCREEN_UV.xy);
	vec3 noise_offset = vec3(0.0, 0.0, 0.0);
	noise_offset += (noise_tex.xyz * 2.0 - vec3(1.0)) * 0.005 * noise_offset_multiplier;

//	Add a line based on a sudden change in depth.
	float depth_diff = 0.0;
	float neg_depth_diff = 0.5;
	if(depth_check){
		float depth = getDepth(SCREEN_UV+noise_offset.xy, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float du = getDepth(SCREEN_UV+noise_offset.xy+vec2(0., -1.) * pixel_size, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dr = getDepth(SCREEN_UV+noise_offset.xy+vec2(1., 0.) * pixel_size, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dd = getDepth(SCREEN_UV+noise_offset.xy+vec2(0., 1.) * pixel_size, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dl = getDepth(SCREEN_UV+noise_offset.xy+vec2(-1., 0.) * pixel_size, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		depth_diff += clamp(du - depth, 0., 1.);
		depth_diff += clamp(dd - depth, 0., 1.);
		depth_diff += clamp(dr - depth, 0., 1.);
		depth_diff += clamp(dl - depth, 0., 1.);
		neg_depth_diff += depth - du;
		neg_depth_diff += depth - dd;
		neg_depth_diff += depth - dr;
		neg_depth_diff += depth - dl;
		neg_depth_diff = clamp(neg_depth_diff, 0., 1.);
//		neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff)*10., 0., 1.);
//		depth_diff = smoothstep(0.5, 1.0, depth_diff);
	}

	//	Add a line based on a sudden change in normal direction.
	float normal_diff = 0.;
	if(normal_check){
		vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV+noise_offset.xy).rgb * 2.0 - 1.0;
		vec3 nu = texture(NORMAL_TEXTURE, SCREEN_UV + noise_offset.xy + vec2(0., -1.) * pixel_size).rgb * 2.0 - 1.0;
		vec3 nr = texture(NORMAL_TEXTURE, SCREEN_UV + noise_offset.xy + vec2(1., 0.) * pixel_size).rgb * 2.0 - 1.0;
		vec3 nd = texture(NORMAL_TEXTURE, SCREEN_UV + noise_offset.xy + vec2(0., 1.) * pixel_size).rgb * 2.0 - 1.0;
		vec3 nl = texture(NORMAL_TEXTURE, SCREEN_UV + noise_offset.xy + vec2(-1., 0.) * pixel_size).rgb * 2.0 - 1.0;
		vec3 normal_edge_bias = (vec3(1., 1., 1.));
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		normal_diff = smoothstep(0.2, 0.8, normal_diff);
		normal_diff = clamp(normal_diff-neg_depth_diff, 0.0, 1.0);
	}

	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	// By default result the tint color. Any other effects are applied later on.
	vec3 final = tint_color;
	vec3 original_color = normalize(screen_tex.rgb);
	// The sky should remain the same color.
	if(depth >= 1.0){
		final = screen_tex.rgb;
	// Return a completely black color when the screen texture is below a threshold.
	}else if(length(screen_tex.rgb) < black_threshold){
		final = vec3(0.0);
	// Make it completely white when screen texture is above a threshold.
	}else if(length(screen_tex.rgb) > white_threshold){
		final = vec3(1.0);
	// If color pass through is enabled then replace the output color with the screen texture color.
	}else if(color_passthrough){
		final = original_color;
	}
	// If the difference in normal or depth is large enough then a line has been found.
	if(normal_check && depth < 1.0){
		vec3 normal_line_color = mix(final, line_color, normal_line_strength);
		final = mix(final, normal_line_color, normal_diff);
	}
	if(depth_check && depth < 1.0){
		vec3 depth_line_color = mix(final, line_color, depth_line_strength);
		final = mix(final, depth_line_color, depth_diff);
	}
	// Apply the sketchy lines based on how dark the scene is.
	vec4 lines_tex = texture(texture_lines, (SCREEN_UV + noise_offset.xy) * lines_texture_scale);

	if(screen_tex.r < 0.01){
		final += vec3(lines_tex.r * -red_weight);
	}
	if(screen_tex.r < 0.1){
		final += vec3(lines_tex.g * -green_weight);
	}
	if(screen_tex.r < 0.25){
		final += vec3(lines_tex.b * -blue_weight);
	}

	vec4 grain_tex = texture(texture_grain, SCREEN_UV * grain_texture_scale);
	// Apply the grain texture on top of the final color.
	final *= clamp(grain_tex.rgb + vec3(1.0 - grain_amount), vec3(0.0), vec3(1.0));

	ALBEDO = final;
}