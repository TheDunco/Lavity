shader_type canvas_item;

// Can make image repeat in the import settings!
uniform float scale : hint_range(0.1, 10) = 1.0;
uniform bool grayScale = false;
uniform vec4 color : source_color = vec4(1.0);
uniform float flashState : hint_range(0,1) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 pixelColor = texture(TEXTURE, UV * scale);
	float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
	vec4 grayScaleVal = vec4(brightness, brightness, brightness, pixelColor.a);

	if(grayScale) {
		COLOR = grayScaleVal;
	}
	else {
		COLOR = mix(pixelColor * color, color, flashState);
		COLOR.a *= pixelColor.a;
		// Swizzeling
		//COLOR.rgb = COLOR.rrr;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
