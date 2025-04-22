// Audio-Reactive Shader Gallery for Windows Terminal
// Includes Terminal blending, Audio input, Effect switching

#define WINDOWS_TERMINAL

Texture2D shaderTexture;
SamplerState samplerState;

// Audio and Control Buffer
cbuffer ControlBuffer {
    float  Time;
    float2 Resolution;
    float4 Background;
    float  AudioLevel;      // 0.0 - 1.0
    float  Bass;
    float  Mid;
    float  Treble;
    float  EffectIndex;     // 0 = Tunnel, 1 = Aurora, 2 = PulseRing
    float  UserParam1;      // For UI slider
    float  UserParam2;      // For UI slider
};

#define PI 3.14159265
#define TAU (2.0 * PI)

float2 Rotate(float2 uv, float a) {
    float s = sin(a), c = cos(a);
    return float2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
}

float hash(float n) {
    return frac(sin(n) * 43758.5453);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = frac(p);
    float a = hash(i.x + i.y * 57.0);
    float b = hash(i.x + 1.0 + i.y * 57.0);
    float c = hash(i.x + (i.y + 1.0) * 57.0);
    float d = hash(i.x + 1.0 + (i.y + 1.0) * 57.0);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

float3 tunnelEffect(float2 uv) {
    float2 p = uv * Resolution / Resolution.y;
    float angle = atan2(p.y, p.x);
    float radius = length(p);
    float speed = 0.4 + AudioLevel * 1.2;
    float twist = angle + Time * speed;
    float depth = 1.0 / (radius + 0.1);
    float shade = noise(float2(twist * 3.0, depth * 4.0));
    return float3(shade * depth, shade * 0.3, 1.0 - shade);
}

float3 auroraEffect(float2 uv) {
    float2 p = uv;
    p.y += sin(p.x * 10.0 + Time * 2.0) * 0.2 * AudioLevel;
    float n = noise(p * 5.0);
    return float3(0.2 + n * 0.8, 0.6 + n * 0.4, 1.0);
}

float3 pulseRingEffect(float2 uv) {
    float2 p = uv;
    float len = length(p);
    float ring = sin((len - Time * 2.0) * 30.0) * 0.5 + 0.5;
    ring *= smoothstep(0.4, 0.0, len);
    ring *= AudioLevel * 2.0;
    return float3(ring, ring * 0.6, 1.0 - ring);
}

float3 applyEffect(float2 uv) {
    if (EffectIndex < 0.5)
        return tunnelEffect(uv);
    else if (EffectIndex < 1.5)
        return auroraEffect(uv);
    else
        return pulseRingEffect(uv);
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
    float2 uv = tex * 2.0 - 1.0;
    uv.x *= Resolution.x / Resolution.y;
    uv.y *= -1.0;

    float3 col = applyEffect(uv);

    float4 fg = shaderTexture.Sample(samplerState, tex);
    float4 sh = shaderTexture.Sample(samplerState, tex - 2.0 / Resolution);

    col = lerp(col, float3(0.0, 0.0, 0.0), sh.w);
    col = lerp(col, fg.rgb, fg.a);

    return float4(col, 1.0);
}
