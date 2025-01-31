shader_type canvas_item;
render_mode unshaded;

uniform sampler2D distortionTexture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Distortion
	vec2 distortedUV = SCREEN_UV + texture(distortionTexture, UV).r * 0.05;
	vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);
	COLOR = screenColor;
}
