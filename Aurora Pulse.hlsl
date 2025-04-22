#define WINDOWS_TERMINAL

Texture2D shaderTexture;
SamplerState samplerState;

#if defined(WINDOWS_TERMINAL)
cbuffer PixelShaderSettings {
    float  Time;
    float  Scale;
    float2 Resolution;
    float4 Background;
};
#define TIME        Time
#define RESOLUTION  Resolution
#else
float time;
float2 resolution;
#define TIME        time
#define RESOLUTION  resolution
#endif

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mix  lerp
#define fract frac
#define mod(x, y) ((x) - (y) * floor((x)/(y)))

static const vec2 unit2 = vec2(1.0, 1.0);
static const vec3 unit3 = vec3(1.0, 1.0, 1.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 hsv2rgb(vec3 c) {
    vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
    return c.z * lerp(vec3(1.0, 1.0, 1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

vec3 particle(vec2 uv, float t) {
    vec3 col = vec3(0.0, 0.0, 0.0);
    float count = 100.0;
    for (float i = 0.0; i < count; i++) {
        float fi = i / count;
        float angle = fi * 6.2831;
        float dist = 0.3 + 0.2 * sin(t + i);
        vec2 pos = 0.5 + dist * vec2(cos(angle), sin(angle));
        float d = length(uv - pos);
        float fade = exp(-20.0 * d);
        vec3 hsv = vec3(fi + t * 0.05, 1.0, 1.0);
        col += hsv2rgb(hsv) * fade;
    }
    return col;
}

vec3 effect(vec2 p) {
    vec2 uv = 0.5 + 0.5 * p;
    return particle(uv, TIME);
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
    vec2 q = tex;
    vec2 p = -1.0 + 2.0 * q;
#if defined(WINDOWS_TERMINAL)
    p.y = -p.y;
#endif
    p.x *= RESOLUTION.x / RESOLUTION.y;

    vec3 col = effect(p);
    vec4 fg = shaderTexture.Sample(samplerState, q);
    vec4 sh = shaderTexture.Sample(samplerState, q - 2.0 * unit2 / RESOLUTION.xy);

    col = mix(col, vec3(0.0, 0.0, 0.0), sh.w);
    col = mix(col, fg.rgb, fg.a);

    return vec4(col, 1.0);
}
