#version 120

#ifndef FOG_MODE
#define FOG_MODE 3 //0 = Off. 1 = Distance based fog (Small performace impact). 2 = Distance based fog with simplex noise (Medium performace impact). 3 = Raymarched fog with simplex noise (Large performace impact) [0 1 2]

#include "raymarchFog.glsl"

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform int isEyeInWater;

const vec3 fogColor = vec3(0.9, 0.9, 1.0);

void main() {
    // Sample and apply gamma correction
    vec4 colorSample = texture2D(colortex0, texCoord);

    #if FOG_MODE != 0

        vec4 fogSample;
        if(isEyeInWater > 0){
            fogSample = vec4(0.0);
        }
        else{
            #if FOG_MODE == 1
                fogSample = vec4(SimpleFog(texCoord), 1.0);
            #elif FOG_MODE == 2
                fogSample = vec4(SimpleNoiseFog(texCoord), 1.0);
            #elif FOG_MODE == 3
                fogSample = vec4(SimpleRayMarchFog(texCoord), 1.0);
            #endif
        }

        vec4 result = vec4(mix(colorSample.rgb, fogColor, fogSample.r), colorSample.a);

		/* DRAWBUFFERS:0 */
        gl_FragData[0] = result;
    #else

	/* DRAWBUFFERS:0 */
    gl_FragData[0] = colorSample;

    #endif
}
#endif
