shader_type canvas_item;

uniform sampler2D curve;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 vecToCenter = vec2(0.5, 0.5) - UV;
	float distToCenter = length(vecToCenter);
	float curveVal = texture(curve, vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter) * 0.6 * curveVal;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - diff);
}
