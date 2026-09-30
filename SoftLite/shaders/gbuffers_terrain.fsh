#version 120
#include "/lib/common.glsl"
#include "/lib/lighting.glsl"
uniform sampler2D texture;
uniform sampler2D lightmap;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec3 normal;
varying vec3 feetPos;
void main() {
    vec4 t = texture2D(texture, texcoord);
    if (t.a < 0.1) discard;
    vec3 albedo = t.rgb * color.rgb;   // color.rgb carries vanilla ambient occlusion / biome tint
    vec3 n = normalize(normal);
    vec2 lm = clamp((lmcoord - 0.03125) * 1.06667, 0.0, 1.0);
    vec3 c = lightScene(albedo, n, lm, feetPos, 1.0, true);
    c = applyFog(c, feetPos);
    gl_FragData[0] = vec4(c, t.a);
}
