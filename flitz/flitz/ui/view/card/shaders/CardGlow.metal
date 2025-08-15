//
//  CardGlow.metal
//  Flitz
//
//  Card glow/bloom effect shader for post-processing
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Uniform structure for SCNTechnique symbols
struct Uniforms {
    float threshold;
    float radius;
    float3 glowColor;
    float intensity;
    float time;
    float _padding;
};

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
};

// Simple vertex shader for full-screen quad
vertex VertexOut glow_vertex(uint vertexID [[vertex_id]]) {
    VertexOut out;
    
    // Create full-screen quad manually
    float2 positions[4] = {
        float2(-1, -1),
        float2( 1, -1),
        float2(-1,  1),
        float2( 1,  1)
    };
    
    float2 texCoords[4] = {
        float2(0, 1),
        float2(1, 1),
        float2(0, 0),
        float2(1, 0)
    };
    
    out.position = float4(positions[vertexID % 4], 0, 1);
    out.texCoords = texCoords[vertexID % 4];
    
    return out;
}

// Extract bright areas for glow
fragment float4 glow_bright_pass(VertexOut in [[stage_in]],
                                 texture2d<float> colorTex [[texture(0)]],
                                 constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    
    float4 color = colorTex.sample(textureSampler, in.texCoords);
    
    // Dynamic threshold based on time for pulsing effect
    float dynamicThreshold = uniforms.threshold * (1.0 + 0.3 * sin(uniforms.time * 2.0));
    
    // Calculate luminance
    float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    
    // Extract bright pixels
    if (luminance > dynamicThreshold) {
        // Boost bright areas
        float boost = smoothstep(dynamicThreshold, dynamicThreshold + 0.3, luminance);
        return float4(color.rgb * (1.0 + boost * 2.0), color.a);
    }
    
    return float4(0.0);
}

// Horizontal gaussian blur
fragment float4 glow_blur_horizontal(VertexOut in [[stage_in]],
                                     texture2d<float> colorTex [[texture(0)]],
                                     constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    
    float2 texelSize = 1.0 / float2(colorTex.get_width(), colorTex.get_height());
    
    /*
    // 간단한 5-tap blur
    float4 color = float4(0.0);
    float blurSize = 3.0;
    
    color += colorTex.sample(textureSampler, in.texCoords + float2(-2.0 * blurSize * texelSize.x, 0.0)) * 0.06;
    color += colorTex.sample(textureSampler, in.texCoords + float2(-1.0 * blurSize * texelSize.x, 0.0)) * 0.24;
    color += colorTex.sample(textureSampler, in.texCoords) * 0.40;
    color += colorTex.sample(textureSampler, in.texCoords + float2( 1.0 * blurSize * texelSize.x, 0.0)) * 0.24;
    color += colorTex.sample(textureSampler, in.texCoords + float2( 2.0 * blurSize * texelSize.x, 0.0)) * 0.06;
    
    return color;
     */
    
    // Dynamic radius for animated glow
    float dynamicRadius = uniforms.radius * (1.0 + 0.2 * sin(uniforms.time * 3.0 + 1.0));
    float blurStep = dynamicRadius * 1.0; // Scale factor for wider blur
    
    // 9-tap gaussian blur with normalized weights
    float4 color = float4(0.0);
    // float weights[9] = {0.0521, 0.0915, 0.1265, 0.1510, 0.1578, 0.1510, 0.1265, 0.0915, 0.0521};
    float weights[9] = {0.0511, 0.0896, 0.1238, 0.1478, 0.1547, 0.1478, 0.1238, 0.0896, 0.0511};


    for (int i = -4; i <= 4; i++) {
        float2 offset = float2(float(i) * blurStep * texelSize.x, 0.0);
        color += colorTex.sample(textureSampler, in.texCoords + offset) * weights[i + 4];
    }
    
    return color;
}

// Vertical gaussian blur
fragment float4 glow_blur_vertical(VertexOut in [[stage_in]],
                                   texture2d<float> colorTex [[texture(0)]],
                                   constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    
    float2 texelSize = 1.0 / float2(colorTex.get_width(), colorTex.get_height());
    
    /*
    // 간단한 5-tap blur
    float4 color = float4(0.0);
    float blurSize = 3.0;
    
    color += colorTex.sample(textureSampler, in.texCoords + float2(0.0, -2.0 * blurSize * texelSize.y)) * 0.06;
    color += colorTex.sample(textureSampler, in.texCoords + float2(0.0, -1.0 * blurSize * texelSize.y)) * 0.24;
    color += colorTex.sample(textureSampler, in.texCoords) * 0.40;
    color += colorTex.sample(textureSampler, in.texCoords + float2(0.0,  1.0 * blurSize * texelSize.y)) * 0.24;
    color += colorTex.sample(textureSampler, in.texCoords + float2(0.0,  2.0 * blurSize * texelSize.y)) * 0.06;
    
    return color;
     */
    
    // Dynamic radius for animated glow
    float dynamicRadius = uniforms.radius * (1.0 + 0.2 * sin(uniforms.time * 3.0 + 1.0));
    float blurStep = dynamicRadius * 1.0; // Scale factor for wider blur
    
    // 9-tap gaussian blur with normalized weights
    float4 color = float4(0.0);
    // float weights[9] = {0.0521, 0.0915, 0.1265, 0.1510, 0.1578, 0.1510, 0.1265, 0.0915, 0.0521};
    float weights[9] = {0.0511, 0.0896, 0.1238, 0.1478, 0.1547, 0.1478, 0.1238, 0.0896, 0.0511};

    for (int i = -4; i <= 4; i++) {
        float2 offset = float2(0.0, float(i) * blurStep * texelSize.y);
        color += colorTex.sample(textureSampler, in.texCoords + offset) * weights[i + 4];
    }
    
    return color;
}

// Combine original image with glow
fragment float4 glow_composite(VertexOut in [[stage_in]],
                               texture2d<float> sceneTex [[texture(0)]],
                               texture2d<float> glowTex [[texture(1)]],
                               constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler(address::clamp_to_edge, filter::linear);
    
    float4 scene = sceneTex.sample(textureSampler, in.texCoords);
    float4 glow = glowTex.sample(textureSampler, in.texCoords);
    
    /*
    float timeVisual = sin(uniforms.time) * 0.5 + 0.5;
    
    return float4(timeVisual, timeVisual, timeVisual, 1.0);
     */
    
    // Animated intensity
    float animatedIntensity = uniforms.intensity * (1.0 + 0.3 * sin(uniforms.time * 1.5));
    
    // Color shift over time for ethereal effect
    float3 animatedColor = uniforms.glowColor;
    animatedColor.r *= (1.0 + 0.1 * sin(uniforms.time * 2.0));
    animatedColor.g *= (1.0 + 0.1 * sin(uniforms.time * 2.3 + 1.0));
    animatedColor.b *= (1.0 + 0.1 * sin(uniforms.time * 2.7 + 2.0));
    
    // Apply glow with color tint
    float3 glowContribution = glow.rgb * animatedColor * animatedIntensity;
    
    // Additive blending for glow
    float3 finalColor = scene.rgb + glowContribution;
    
    return float4(finalColor, scene.a);
}
