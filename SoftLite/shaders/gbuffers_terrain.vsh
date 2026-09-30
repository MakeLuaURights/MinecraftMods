#version 120
#include "/lib/common.glsl"
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
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
    feet = applySway(feet + cameraPosition, mc_Entity.x, gl_MultiTexCoord0.t < mc_midTexCoord.t, frameTimeCounter) - cameraPosition;
    feetPos = feet;
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(feet, 1.0));
}
