#version 120
#include "/lib/common.glsl"
#include "/lib/lighting.glsl"
uniform sampler2D texture;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 feetPos;
void main() {
    vec4 t = texture2D(texture, texcoord) * color;
    vec2 lm = clamp((lmcoord - 0.03125) * 1.06667, 0.0, 1.0);
    vec3 c = lightScene(t.rgb, normalize(normal), lm, feetPos, 1.0, false);
    // soft sun glint on the surface
    vec3 V = normalize(-(feetPos));
    float glint = pow(max(dot(normalize(shadowLightPosition), normalize(normal)), 0.0), 2.0) * 0.06 * dayAmount();
    c += glint;
    c = applyFog(c, feetPos);
    gl_FragData[0] = vec4(c, t.a);
}
