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
    float2 offsetUp = position - float2(0.0, texelHeight);
    
    // 위치에서의 색상 샘플링
    half3 colorCenter = layer.sample(position).rgb;
    half3 colorRight = layer.sample(offsetRight).rgb;
    half3 colorUp = layer.sample(offsetUp).rgb;
    
    // alpha
    half alphaCenter = layer.sample(position).a;
    
    if (alphaCenter < 0.05) {
        // alpha가 낮으면 노멀 맵을 투명하게 설정
        return half4(0.0, 0.0, 0.0, 0.0);
    }
    
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
    return half4(normalRGB, alphaCenter);
}

// 흑백(루마) + 정규화
// - position: 0..1 UV
// - layer: 입력 이미지
// - size: 입력 텍스처 픽셀 크기 (w,h)
// - minVal/maxVal: 전역 정규화 범위. maxVal <= minVal 이면 3x3 로컬 정규화 사용
// - gamma: 가감마(1.0=변화 없음). 0.8~1.4 정도로 미세 조정 추천
[[ stitchable ]]
half4 grayscaleNormalize(float2 position,
                         SwiftUI::Layer layer,
                         float2 size,
                         float  minVal,
                         float  maxVal,
                         float  gamma)
{
    // 1) 샘플 → 루마(흑백)
    //    (sRGB 계열 가중치. 네가 앞서 쓰던 0.299/0.587/0.114 그대로 맞춤)
    const half4 c  = layer.sample(position);
    auto   lumaOf  = [&](float2 uv) -> float {
        half3 rgb = layer.sample(uv).rgb;
        return dot((float3)rgb, float3(0.299, 0.587, 0.114));
    };

    float luma = lumaOf(position);
    
    return half4(luma, luma, luma, c.a);
    
    /*

    // 2) 정규화 범위 결정
    float lo = minVal;
    float hi = maxVal;

    // maxVal <= minVal 이면 "로컬 3x3"로 자동 정규화
    if (hi <= lo) {
        float2 texel = 1.0 / max(size, float2(1.0, 1.0));
        float lmin = 1e9;
        float lmax = -1e9;

        // 3x3 이웃 샘플로 로컬 대비 잡기 (간단한 지역 히스토그램 느낌)
        // [-1..1] x [-1..1] 커널
        for (int j = -1; j <= 1; ++j) {
            for (int i = -1; i <= 1; ++i) {
                float2 uv = position + float2(i, j) * texel;
                float v = lumaOf(uv);
                lmin = fmin(lmin, v);
                lmax = fmax(lmax, v);
            }
        }

        // 범위가 너무 좁으면 약간 벌려 주기(밴딩 방지)
        float eps = 1e-5;
        if (lmax - lmin < 1e-3) {
            lmin = luma - 0.5e-3;
            lmax = luma + 0.5e-3;
        }
        lo = lmin;
        hi = lmax + eps;
    } else {
        // 글로벌 범위 보호
        hi = max(hi, lo + 1e-6);
    }

    // 3) [lo..hi] → [0..1]
    float v = (luma - lo) / (hi - lo);
    v = clamp(v, 0.0, 1.0);

    // 4) 감마 조정(선택)
    float g = max(gamma, 1e-6);
    v = pow(v, 1.0 / g);

    // 알파는 원본 유지
    return half4(half(v), half(v), half(v), c.a);
     */
}

[[ stitchable ]]
half4 genNormalMapEx2(float2 uv, SwiftUI::Layer layer, float2 size, float strength)
{
    bool flipGreen = true;
    bool invertHeight = true;
    
    float2 texel = 1.0 / size;

    // 샘플/명도 → 높이
    auto H = [&](float2 p) -> float {
        half4 c = layer.sample(p);
        float lum = dot(c.rgb, half3(0.299, 0.587, 0.114));
        return invertHeight ? (1.0 - lum) : lum;
    };

    half a = layer.sample(uv).a;
    if (a < 0.05) return half4(0.5, 0.5, 1.0, 0.0); // 중립 노멀

    // 중앙차분 (Y는 스위프트UI 좌표 보정)
    float hx = H(uv + float2(texel.x, 0)) - H(uv - float2(texel.x, 0));
    float hy = H(uv - float2(0, texel.y)) - H(uv + float2(0, texel.y)); // Y-아래 증가 보정
    if (!flipGreen) hy = -hy; // 상황에 따라 토글

    float3 n = normalize(float3(-hx, -hy, 2.0/strength)); // Z 스케일은 감도 맞춤
    half3 rgb = half3(n * 0.5 + 0.5);
    return half4(rgb, a);
}
