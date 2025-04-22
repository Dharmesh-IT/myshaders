// Aurora Reactive Shader for Windows Terminal
// Audio-reactive, with color pulse and blend control

#define WINDOWS_TERMINAL

Texture2D shaderTexture;
SamplerState samplerState;
StructuredBuffer<float> AudioLevels;

cbuffer PixelShaderSettings {
  float Time;
  float Scale;
  float2 Resolution;
  float4 Background;
  float BlendFactor;     // 0 = terminal only, 1 = shader only
  float RainbowShift;    // controlled via slider
  float IntensityBoost;  // control pulse strength
};

#define TIME        Time
#define RESOLUTION  Resolution
#define PI          3.141592654
#define TAU         (2.0*PI)

float2 Rotate(float2 p, float a) {
  float s = sin(a), c = cos(a);
  return float2(c*p.x - s*p.y, s*p.x + c*p.y);
}

float hash(float n) {
  return frac(sin(n) * 43758.5453);
}

float noise(float2 p) {
  float2 i = floor(p);
  float2 f = frac(p);
  f = f*f*(3.0-2.0*f);
  float a = hash(i.x + i.y * 57.0);
  float b = hash(i.x + 1.0 + i.y * 57.0);
  float c = hash(i.x + (i.y + 1.0) * 57.0);
  float d = hash(i.x + 1.0 + (i.y + 1.0) * 57.0);
  return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

float audioReactivePulse(float2 uv) {
  float sum = 0.0;
  [unroll(64)]
  for (uint i = 0; i < 64; ++i) {
    float band = AudioLevels[i] * IntensityBoost;
    float dist = abs(uv.x - (float(i)/64.0));
    sum += band * exp(-dist * 40.0);
  }
  return saturate(sum);
}

float3 hsv2rgb(float3 c) {
  float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
  float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

float3 render(float2 uv) {
  uv -= 0.5;
  uv.x *= RESOLUTION.x / RESOLUTION.y;

  float t = TIME * 0.2;
  uv = Rotate(uv, 0.05*sin(TIME*0.5));

  float id = floor(uv.y * 20.0);
  float shift = id * 0.2 + t;
  float stripe = sin((uv.x * 8.0 + shift) * TAU);
  float pulse = audioReactivePulse(uv);

  float3 color = hsv2rgb(float3(frac(shift * 0.1 + RainbowShift), 0.9, 1.0));
  color *= (stripe * 0.5 + 0.5) * pulse;

  return color;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
  float2 uv = tex;
  float3 fxColor = render(uv);

  float4 fg = shaderTexture.Sample(samplerState, tex);
  float4 blended = lerp(fg, float4(fxColor, 1.0), BlendFactor);

  return blended;
}
