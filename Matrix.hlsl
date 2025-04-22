#define WINDOWS_TERMINAL

Texture2D shaderTexture;
SamplerState samplerState;

// Structured audio input (amplitude over time)
StructuredBuffer<float> AudioAmplitudes;

// === SHADER SETTINGS ===
cbuffer PixelShaderSettings {
    float Time;
    float Scale;
    float2 Resolution;
    float4 Background;
    float AudioLevel; // Normalized current beat amplitude
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

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// === MATRIX FALLING CHARACTERS ===
static const int numChars = 94; // Number of characters in the ASCII set
static const int charWidth = 10; // Width of each falling character
static const int charHeight = 20; // Height of each falling character

// === Matrix Rain Function ===
vec3 matrixRain(vec2 uv, float time, float audioLevel) {
    vec3 col = float3(0.0, 0.0, 0.0); // Initialize as black

    // Adjust number of falling characters to fit within the screen width
    float totalChars = 40.0;

    for (float i = 0.0; i < totalChars; i++) {
        float index = i / totalChars;
        float columnX = index * 2.0 - 1.0;  // Spread characters across screen width
        float columnY = mod(time + index * 0.5, 1.0); // Make characters "fall"

        // Character positions
        vec2 charPos = float2(columnX, columnY);  // Falling position

        // Distance to the character's path
        float dist = length(uv - charPos);
        
        // Only render characters when close to the falling path
        if (dist < 0.05) {
            float charIntensity = sin(TIME * 10.0 + index * 5.0) * 0.5 + 0.5;  // Pulsing effect
            charIntensity *= audioLevel * 2.0; // Amplify intensity with audio level

            // Green color for the matrix rain effect
            vec3 color = float3(0.0, 1.0, 0.0);  // Constant green color

            // Combine the character color with intensity
            vec3 charColor = color * charIntensity;

            // Add the character color to the background
            col += charColor;
        }
    }

    return col;
}

// === BACKGROUND GLOW ===
vec3 backgroundGlow(vec2 uv) {
    return float3(0.0, 0.0, 0.0); // Black background
}

// === FINAL PIXEL ===
float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET {
    vec2 uv = -1.0 + 2.0 * tex;
    uv.x *= RESOLUTION.x / RESOLUTION.y;  // Adjust for aspect ratio

    vec3 background = backgroundGlow(uv);
    vec3 rain = matrixRain(uv, TIME, AudioLevel);

    // Blend background and falling characters
    vec3 finalColor = mix(background, rain, rain.x);
    
    return float4(finalColor, 1.0);
}
