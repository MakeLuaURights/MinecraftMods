#include "/lib/settings.glsl"

// Shadow map distortion: more resolution near the player (must match in shadow + terrain passes)
vec3 distortShadow(vec3 p) {
    float f = length(p.xy) * 0.85 + 0.15;
    return vec3(p.xy / f, p.z * 0.5);
}

// Cheap wind. type: 1 = leaves (whole block), 2 = plants (top only)
vec3 applySway(vec3 w, float id, bool isTop, float t) {
#ifdef SWAY
    float amp = 0.0;
    if (id > 10000.5 && id < 10001.5) amp = 0.035;
    else if (id > 10001.5 && id < 10002.5 && isTop) amp = 0.07;
    if (amp > 0.0) {
        float ph = w.x * 0.9 + w.z * 0.7;
        w.x += sin(t * 1.6 + ph) * amp * SWAY_STRENGTH;
        w.z += cos(t * 1.3 + ph * 1.3) * amp * 0.7 * SWAY_STRENGTH;
        if (id < 10001.5) w.y += sin(t * 1.9 + ph * 1.7) * amp * 0.4 * SWAY_STRENGTH;
    }
#endif
    return w;
}

float waterWave(vec3 w, float t) {
#ifdef WATER_WAVES
    return (sin(w.x * 1.3 + t * 1.5) * 0.5 + sin(w.z * 1.7 + t * 1.2) * 0.5
          + sin((w.x + w.z) * 0.8 + t * 0.9) * 0.3) * 0.03 * WAVE_STRENGTH;
#else
    return 0.0;
#endif
}
