//
//  FlitzRendererBaseView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    public protocol RendererView: View {
        associatedtype NormalMapView: View
        /// 입체 표현을 위한 노말 맵 생성 셰이더를 적용한 뷰를 반환합니다.
        var normalMapBody: NormalMapView { get }
    }
}


extension View {
    func applyNormalMapShader() -> some View {
        self.visualEffect { content, proxy in
            content
                // .layerEffect(ShaderLibrary.customAA(.float2(proxy.size)), maxSampleOffset: .zero)
                .layerEffect(ShaderLibrary.genNormalMapEx(.float2(proxy.size), .float(1.0)),
                             maxSampleOffset: CGSize(width: 4, height: 4))
        }
    }
}
