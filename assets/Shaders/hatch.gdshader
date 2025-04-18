shader_type spatial;

uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D normal_texture: hint_normal_roughness_texture;
uniform sampler2D depth_texture: hint_depth_texture;


uniform sampler2D hatch1: filter_nearest,repeat_enable;
uniform sampler2D hatch2: filter_nearest,repeat_enable;
uniform sampler2D hatch3: filter_nearest,repeat_enable;

uniform float threshold1 :hint_range(0.0, 1.0, 0.001)= 0.5;
uniform float threshold2 :hint_range(0.0, 1.0, 0.001)= 0.6;

void vertex(){
    // Godot v4.3
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
    // before Godot v4.3
    // POSITION = vec4(VERTEX,1.0);
}

void fragment() {
    vec3 screen_color = texture(screen_texture,SCREEN_UV).rgb;

    //Gray scale;
    float luminance = dot(screen_color, vec3(0.299, 0.587, 0.114));

    //Reversed ambient occlusion
    float r_channel = screen_color.r;
    float pow_r = pow(r_channel,0.3);
    float inverse_pow_r = 1.0 - pow_r;
    luminance -= inverse_pow_r;
    luminance = 1.0 - luminance;
    vec3 final_color = vec3(luminance);


    vec3 normal_sample = normalize(texture(normal_texture, SCREEN_UV).rgb * 2.0 - 1.0);
    vec2 distorted_uv = SCREEN_UV + normal_sample.xy * 2.0 ;


    if (luminance > 0.001){
        if (luminance < threshold1){
            vec3 hatch1_color = 1.0 - texture(hatch1,distorted_uv * 15.0).rgb;
            final_color *= hatch1_color;

        } else if ( luminance < threshold2){
            vec3 hatch2_color = 1.0 - texture(hatch2,distorted_uv * 15.0).rgb;
            final_color *= hatch2_color;
        } else{
            vec3 hatch3_color = 1.0 - texture(hatch3,distorted_uv * 15.0).rgb;
            final_color *= hatch3_color;
        }

    }
    final_color = mix(vec3(1.0),vec3(0.0),final_color * 20.0);
    ALBEDO = final_color ;
}