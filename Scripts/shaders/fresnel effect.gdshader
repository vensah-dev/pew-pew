shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform float start = 3.0;

uniform vec4 colour1: source_color;
uniform vec4 colour2: source_color;

#include "res://Scripts/shaders/funcs.gdshaderinc"

void fragment(){
	float f = fresnel(start, NORMAL, VIEW);
	ALPHA = clamp(mix(colour1.a, colour2.a, f), 0.0, 1.0);
	ALBEDO = mix(colour1.rgb, colour2.rgb, f);
}
