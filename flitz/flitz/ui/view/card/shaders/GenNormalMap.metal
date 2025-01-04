//
//  GenNormalMap.metal
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

// Vertex 데이터 구조체
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};


[[ stitchable ]] half4 genNormalMap(float2 position, SwiftUI::Layer layer, float2 size) {
    // currentColor에서 높이 값 추출 (R 채널 사용)
    float heightCenter = layer.sample(position).r;
    
    // 텍스처 좌표에서의 그레디언트 계산
    float texelWidth = 1.0 / size.x;
    float texelHeight = 1.0 / size.y;

    float heightRight = layer.sample(position + float2(texelWidth, 0.0)).r;
    float heightUp = layer.sample(position + float2(0.0, texelHeight)).r;

    // 높이 차이를 텍셀 크기로 나누어 기울기 계산
    float dhdx = (heightRight - heightCenter) / texelWidth;
    float dhdy = (heightUp - heightCenter) / texelHeight;

    // 법선 벡터 계산 (X: -dhdx, Y: -dhdy, Z: 1)
    half3 normal = normalize(half3(-dhdx,    // -dhdx
                                   -dhdy,    // -dhdy
                                   1.0));    // z는 기본값

    // RGB 값으로 매핑 (0~1 범위로 변환)
    half3 normalRGB = normal * 0.5 + 0.5;

    // 노멀 맵 출력
    return half4(normalRGB, 1.0);
}


[[ stitchable ]] half4 genNormalMapEx(float2 position, SwiftUI::Layer layer, float2 size, float strength) {
    // 텍셀 크기 계산
    float texelWidth = 1.0 / size.x;
    float texelHeight = 1.0 / size.y;
    
    float2 offsetRight = position + float2(texelWidth, 0.0);
    float2 offsetUp = position + float2(0.0, texelHeight);
    
    // 위치에서의 색상 샘플링
    half3 colorCenter = layer.sample(position).rgb;
    half3 colorRight = layer.sample(offsetRight).rgb;
    half3 colorUp = layer.sample(offsetUp).rgb;
    
    // half alpha = layer.sample(position).a;

    // 명도 계산 (RGB를 활용하여 명도 값 추출)
    float luminanceCenter = dot(colorCenter, half3(0.299, 0.587, 0.114));
    float luminanceRight = dot(colorRight, half3(0.299, 0.587, 0.114));
    float luminanceUp = dot(colorUp, half3(0.299, 0.587, 0.114));

    // 높이 값 반전 (텍스트를 높게 만들기 위해)
    float heightCenter = 1.0 - luminanceCenter;
    float heightRight = 1.0 - luminanceRight;
    float heightUp = 1.0 - luminanceUp;

    // 높이 차이를 텍셀 크기로 나누어 기울기 계산
    float dhdx = ((heightRight - heightCenter) / texelWidth) * strength;
    float dhdy = ((heightUp - heightCenter) / texelHeight) * strength;

    // 법선 벡터 계산 (X: -dhdx, Y: -dhdy, Z: 1)
    half3 normal = normalize(half3(-dhdx,    // -dhdx
                                   -dhdy,    // -dhdy
                                   1.0));    // z는 기본값

    // RGB 값으로 매핑 (0~1 범위로 변환)
    half3 normalRGB = normal * 0.5 + 0.5;

    // 노멀 맵 출력
    return half4(normalRGB, 1.0);
}
