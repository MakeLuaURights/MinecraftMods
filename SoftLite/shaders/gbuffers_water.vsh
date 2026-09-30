#version 120
#include "/lib/common.glsl"
attribute vec4 mc_Entity;
uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 feetPos;
void main() {
    texcoord = gl_MultiTexCoord0.st;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
    color = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 feet = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
    if (mc_Entity.x > 10002.5 && mc_Entity.x < 10003.5)
        feet.y += waterWave(feet + cameraPosition, frameTimeCounter);
    feetPos = feet;
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(feet, 1.0));
}
