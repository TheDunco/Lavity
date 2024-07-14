// chromatic aberration
//---------------------------------

shader_type canvas_item;

//uniform vec2 r_displacement = vec2(3.0, 0.0);
//uniform vec2 g_displacement = vec2(0.0, 0.0);
//uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float displacement = 3.0;

void fragment()
{
	vec2 r_displacement = vec2(displacement, 0.0);
	vec2 b_displacement = vec2(-displacement, 0.0);
	vec4 input_color = texture(TEXTURE, UV);
	float r = texture(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*r_displacement), input_color.a).r;
	//float g = texture(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*g_displacement), input_color.a).g;
	float b = texture(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*b_displacement), input_color.a).b;
	
	COLOR = vec4(r, input_color.g, b, input_color.a);
}