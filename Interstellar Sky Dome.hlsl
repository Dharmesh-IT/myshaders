#define WINDOWS_TERMINAL

Texture2D shaderTexture;
SamplerState samplerState;

// Structured audio input (amplitude over time)
StructuredBuffer<float> AudioAmplitudes;

// === SHADER SETTINGS ===
cbuffer PixelShaderSettings {
  float  Time;
  float  Scale;
  float2 Resolution;
  float4 Background;
  float  AudioLevel; // Normalized current beat amplitude
};

#define TIME        Time
#define RESOLUTION  Resolution

// === HELPERS ===
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mix  lerp
#define fract frac

float mod(float x, float y) { return x - y * floor(x / y); }

vec3 hsv2rgb(vec3 c) {
  vec3 p = abs(fract(c.xxx + float3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
  return c.z * mix(float3(1.0, 1.0, 1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

float hash(float n) {
  return fract(sin(n) * 43758.5453123);
}

// === PARTICLE STARFIELD ===
vec3 starfield(vec2 uv, float time, float intensity) {
  vec3 col = float3(0, 0, 0);
  float count = 700.0; // Increase particle count for fuller space
  for (float i = 0.0; i < count; i++) {
    float fi = i / count;
    float angle = fi * 6.2831;
    float dist = fract(fi + time * 0.1 + AudioLevel * 0.2);
    float size = 0.005 + 0.005 * hash(i); // Larger stars for better visibility
    float fade = pow(1.0 - dist, 4.0);  // Sharper fading

    vec2 offset = float2(cos(angle), sin(angle)) * dist * 3.0; // Increase particle spread
    float d = length(uv - offset);
    col += fade * smoothstep(size, 0.0, d) * hsv2rgb(float3(fract(fi + time * 0.1), 0.8, 1.0));
  }
  return col;
}

// === SKY GRADIENT BACKDROP ===
vec3 skyGradient(vec2 uv) {
  float y = uv.y * 0.6 + 0.4; // Increase sky stretch on the y-axis
  vec3 top = hsv2rgb(float3(0.6 + 0.2 * sin(TIME * 0.2), 0.3, 0.15)); // Deep cosmic purples
  vec3 bottom = hsv2rgb(float3(0.7, 0.3, 0.05)); // Darker hues, nebula-like
  return mix(bottom, top, y);
}

// === FINAL PIXEL ===
float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
  vec2 uv = -1.0 + 2.0 * tex;
  uv.x *= RESOLUTION.x / RESOLUTION.y;  // Adjust for aspect ratio
  uv.y *= 1.2; // Stretch vertically for broader effect

  vec3 sky = skyGradient(uv);
  vec3 stars = starfield(uv, TIME, AudioLevel);
  vec3 finalColor = sky + stars;

  // Post blend with terminal content
  vec4 fg = shaderTexture.Sample(samplerState, tex);
  vec4 sh = shaderTexture.Sample(samplerState, tex - 2.0 / RESOLUTION.xy);
  finalColor = mix(finalColor, 0.0, sh.w);
  finalColor = mix(finalColor, fg.rgb, fg.a);

  return float4(finalColor, 1.0);
}
