//
//  Antialias.metal
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/24/24.
//
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;


[[ stitchable ]] half4 customAA(float2 position, SwiftUI::Layer layer, float2 size) {
    // 현재 픽셀의 색상
    half4 currentPixel = layer.sample(position).rgba;

    float2 texelSize = 1.0 / size;
    
    // 주변 픽셀 샘플링
    half4 topPixel = layer.sample(position + float2(0.0, texelSize.y)).rgba;
    half4 bottomPixel = layer.sample(position - float2(0.0, texelSize.y)).rgba;
    half4 leftPixel = layer.sample(position - float2(texelSize.x, 0.0)).rgba;
    half4 rightPixel = layer.sample(position + float2(texelSize.x, 0.0)).rgba;
    
    
   // 평균화하여 블렌딩
    half4 blendedColor = (currentPixel + topPixel + bottomPixel + leftPixel + rightPixel) / 5.0;
    
    return blendedColor;
}
