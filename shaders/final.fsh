#version 120

#ifndef TONEMAP
#define TONEMAP 2 //[0 1 2 3]
#endif

varying vec2 texCoord;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

#include "lib/postprocessing/tonemappers.glsl"
#include "lib/postprocessing/bloom.glsl"

#define Saturation 1.00
#define Vibrance 1.00

vec3 colorSaturation(vec3 x){
	float grayv = (x.r + x.g + x.b) / 3.0;
	float grays = grayv;
	if (Saturation < 1.0) grays = dot(x,vec3(0.299, 0.587, 0.114));

	float mn = min(x.r, min(x.g, x.b));
	float mx = max(x.r, max(x.g, x.b));
	float sat = (1.0 - (mx - mn)) * (1.0-mx) * grayv * 5.0;
	vec3 lightness = vec3((mn + mx) * 0.5);

	x = mix(x,mix(x,lightness, 1.0 - Vibrance), sat);
	x = mix(x, lightness, (1.0 - lightness) * (2.0 - Vibrance) / 2.0 * abs(Vibrance - 1.0));

	return x * Saturation - grays * (Saturation - 1.0);
}

#define Exposure 1.0
#define ExtraBrightness 0.08

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    //color = bloom(texCoord);

    // color *= Exposure;
    // color += ExtraBrightness;

    //color = colorSaturation(color);

    // #if TONEMAP == 1
    //     color = BSLTonemap(color);
    // #elif TONEMAP == 2
    //     color = aces(color);
    // #elif TONEMAP == 3
    //     color = filmic(color);
    // #endif

    gl_FragColor = vec4(color, 1.0);
}
