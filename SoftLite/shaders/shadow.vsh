#version 120
#include "/lib/common.glsl"
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
uniform mat4 shadowModelView, shadowModelViewInverse;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
varying vec2 texcoord;
varying vec4 color;
void main() {
    texcoord = gl_MultiTexCoord0.st;
    color = gl_Color;
    vec4 p = shadowModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
    p.xyz = applySway(p.xyz + cameraPosition, mc_Entity.x, gl_MultiTexCoord0.t < mc_midTexCoord.t, frameTimeCounter) - cameraPosition;
    vec4 sp = gl_ProjectionMatrix * (shadowModelView * p);
    sp.xyz = distortShadow(sp.xyz);
    gl_Position = sp;
}
