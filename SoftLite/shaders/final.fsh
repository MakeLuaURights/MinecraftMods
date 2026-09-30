#version 120
#include "/lib/settings.glsl"
const int shadowMapResolution = 1024;
const float shadowDistance = 64.0;
const float sunPathRotation = -25.0;
const float ambientOcclusionLevel = 1.0;
uniform sampler2D colortex0;
varying vec2 texcoord;
void main() {
    vec3 c = texture2D(colortex0, texcoord).rgb;
    float l = dot(c, vec3(0.299, 0.587, 0.114));
    c = mix(vec3(l), c, SATURATION);
    c = c * c * (3.0 - 2.0 * c) * 0.25 + c * 0.75;   // gentle contrast curve
#ifdef VIGNETTE
    vec2 d = texcoord - 0.5;
    c *= 1.0 - dot(d, d) * 0.55;
#endif
    gl_FragColor = vec4(c, 1.0);
}
