// Shared fragment lighting. All in gamma space for speed.
uniform sampler2D shadowtex0;
uniform mat4 shadowModelView, shadowProjection;
uniform vec3 shadowLightPosition, sunPosition, upPosition, fogColor;
uniform float rainStrength, far;
uniform int isEyeInWater;

float dayAmount() {
    return smoothstep(-0.12, 0.22, dot(normalize(sunPosition), normalize(upPosition)));
}

float getShadow(vec3 feetPos, float ndl) {
#ifdef SHADOWS
    vec4 sp = shadowProjection * (shadowModelView * vec4(feetPos, 1.0));
    sp.xyz = distortShadow(sp.xyz) * 0.5 + 0.5;
    if (sp.x < 0.0 || sp.x > 1.0 || sp.y < 0.0 || sp.y > 1.0) return 1.0;
    float bias = 0.0012 + (1.0 - ndl) * 0.0015;
    float z = sp.z - bias;
    float px = 1.0 / 1024.0;
    float s = 0.0;
    s += step(z, texture2D(shadowtex0, sp.xy + vec2( px,  px) * 0.75).r);
    s += step(z, texture2D(shadowtex0, sp.xy + vec2(-px,  px) * 0.75).r);
    s += step(z, texture2D(shadowtex0, sp.xy + vec2( px, -px) * 0.75).r);
    s += step(z, texture2D(shadowtex0, sp.xy + vec2(-px, -px) * 0.75).r);
    return s * 0.25;
#else
    return 1.0;
#endif
}

vec3 lightScene(vec3 albedo, vec3 normalView, vec2 lm, vec3 feetPos, float ao, bool useShadow) {
    float day = dayAmount();
    vec3 L = normalize(shadowLightPosition);
    float ndl = dot(normalView, L);
    float direct = clamp(ndl * 0.8 + 0.2, 0.0, 1.0);      // soft wrap lighting
    float sh = useShadow ? getShadow(feetPos, clamp(ndl, 0.0, 1.0)) : 1.0;
    float skyL = lm.y * lm.y;
    float rain = 1.0 - rainStrength * 0.6;

    vec3 ambDay   = mix(vec3(0.62, 0.70, 0.82), vec3(0.70, 0.74, 0.80), rainStrength);
    vec3 ambNight = vec3(0.09, 0.11, 0.20);
    vec3 amb = mix(ambNight, ambDay, day) * skyL;

    vec3 sunCol  = mix(vec3(0.20, 0.25, 0.42), vec3(1.0, 0.92, 0.78), day);
    float sunPow = mix(0.25, 0.75, day) * rain;
    vec3 sun = sunCol * sunPow * direct * sh * smoothstep(0.3, 0.9, lm.y);

    float b = lm.x * lm.x;
    vec3 blk = vec3(1.0, 0.72 + 0.12 * (1.0 - WARM_LIGHT * 0.5), 0.45 + 0.2 * (1.0 - WARM_LIGHT * 0.5)) * b * 1.15;

    vec3 light = amb + sun + blk + vec3(0.03);
    return albedo * min(light, vec3(1.25)) * ao;
}

vec3 applyFog(vec3 col, vec3 feetPos) {
    float d = length(feetPos);
    float start = isEyeInWater == 1 ? 0.0 : far * 0.65;
    float end = isEyeInWater == 1 ? 32.0 : far;
    return mix(col, fogColor, clamp((d - start) / (end - start), 0.0, 1.0));
}
