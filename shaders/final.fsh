#version 120

#ifndef FOG_MODE
#define FOG_MODE 2 //0 = Distance based fog (Small performace impact). 1 = Distance based fog with simplex noise (Medium performace impact). 2 = Raymarched fog with simplex noise (Large performace impact) [0 1 2]

#include "raymarchFog.glsl"

varying vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform int isEyeInWater;

const vec3 fogColor = vec3(0.9, 0.9, 1.0);

void main() {
    // Sample and apply gamma correction
    vec4 colorSample = texture2D(colortex0, texCoord);

    vec4 fogSample;
    if(isEyeInWater > 0){
        fogSample = vec4(0.0);
    }
    else{
        #if FOG_MODE == 0
            fogSample = vec4(SimpleFog(texCoord), 1.0);
        #elif FOG_MODE == 1
            fogSample = vec4(SimpleNoiseFog(texCoord), 1.0);
        #elif FOG_MODE == 2
            fogSample = vec4(SimpleRayMarchFog(texCoord), 1.0);
        #endif
    }

    vec4 result = vec4(mix(colorSample.rgb, fogColor, fogSample.r), colorSample.a);

    gl_FragColor = result;

    // vec3 colorLinear = pow(texture2D(colortex0, texCoord).rgb, vec3(2.2));
    // colorLinear = aces_tonemap(colorLinear);
    // vec3 colorGamma = pow(colorLinear, vec3(1/2.2)) - 0.1;
    //gl_FragColor = vec4(colorGamma, 1.0);
}
#endif