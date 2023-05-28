
#include "noise_simplex.glsl"

uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;

const float fogSteps = 16.0;
const float fogDensity = 1.0;
const float extinctionCoef = 0.01;
const float ambientFog = 0.01;
const float timeScale = 0.005;

vec4 pixelToView(vec2 texCoord) {
    vec4 pos = vec4(texCoord * 2.0 - 1.0, texture2D(depthtex0, texCoord).r, 1.0);
    pos = gbufferProjectionInverse * pos;
    pos /= pos.w;
    pos = gbufferModelViewInverse * vec4(pos.xyz, 1.0);
    return pos;
}

vec3 SimpleFog(vec2 texCoord){
    vec3 endPos = pixelToView(texCoord).xyz;
    float rayLength = length(endPos);
    float fogFactor = exp(-(extinctionCoef * fogDensity * rayLength));
    return vec3((1.0 - fogFactor) + ambientFog);
}

vec3 SimpleNoiseFog(vec2 texCoord){
    vec3 endPos = pixelToView(texCoord).xyz;

    vec3 noisePos = ((cameraPosition * 2.0) + endPos) * 0.1;
    noisePos.x = noisePos.x + (worldTime * timeScale);
    noisePos.y = noisePos.y + (worldTime * timeScale);
    float simplexValue = snoise(noisePos) * 0.1;

    float rayLength = length(endPos);
    float fogFactor = exp(-(extinctionCoef * (fogDensity + simplexValue) * rayLength));
    return vec3((1.0 - fogFactor) + ambientFog);
}

vec3 SimpleRayMarchFog(vec2 texCoord){
    vec3 endPos = pixelToView(texCoord).xyz;
    float rayLength = length(endPos);

    if(rayLength > 500.0){
        return SimpleFog(texCoord);
    }

    // divide the steps evenly along the ray length
    float stepSize = rayLength / fogSteps;

    // Start marching from the camera position
    vec3 currentPos = vec3(0.0);
    vec3 direction = (endPos.xyz - currentPos) / rayLength;

    vec3 worldPos = (cameraPosition * 1.5) + currentPos;
    vec3 noisePos = worldPos * 0.03;
    float simplexValue = snoise(noisePos) * 0.1;

    uint seed = 0x568437adU;
    float result = 0.0;
    for(int i = 0; i < fogSteps; i++){
        noisePos.x = noisePos.x + (worldTime * timeScale);
        noisePos.y = noisePos.y + (worldTime * timeScale);
        simplexValue = snoise(noisePos) * 0.08;

        float fogValue = (fogDensity / fogSteps) + simplexValue;

        result += fogValue;

        //Extend the ray by a step in the ray direction and update positions
        currentPos += direction * stepSize;
        worldPos = (cameraPosition * 1.5) + currentPos;
        noisePos = worldPos * 0.02;
    }
    float fogFactor = exp(-(extinctionCoef * result * rayLength));
    return vec3((1.0 - fogFactor) + ambientFog);
}
