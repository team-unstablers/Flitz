//
//  FlitzRendererBaseView.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    
    public protocol RendererView: View {
        associatedtype Element: Flitz.Element
        
        var element: Element { get }
        
        init(element: Element)
    }
    
    public protocol NormalMapRendererView: View {
        associatedtype Element: Flitz.Element
        
        var element: Element { get }
        
        init(element: Element)
    }
    
    enum DisplayMode {
        case `default`
        case normalMap
    }
    
    public struct ElementView<Element: Flitz.Element,
                              Renderer: RendererView,
                              NormalMapRenderer: NormalMapRendererView>: View
    where Renderer.Element == Element,
          NormalMapRenderer.Element == Element
    {
        @Environment(\.fzDisplayMode)
        private var displayMode: DisplayMode
        
        @ObservedObject
        var element: Element
        
        var eventHandler: (FZTransformEvent) -> Void
        
        @State
        var delta: Flitz.Transform = .zero
        
        var body: some View {
            ZStack {
                switch displayMode {
                case .default:
                    Renderer(element: element)
                        .onTapGesture {
                            eventHandler(.edit)
                        }
                        .applyFZTransform(element.transform, delta: delta, editable: true, eventHandler: eventHandler)
                case .normalMap:
                    NormalMapRenderer(element: element)
                        .applyFZTransform(element.transform, delta: delta, eventHandler: eventHandler)
                }
            }
            .zIndex(Double(element.zIndex))
        }
    }
}

typealias FZDisplayMode = Flitz.Renderer.DisplayMode


extension View {
    @ViewBuilder
    func mode(_ mode: FZDisplayMode) -> some View {
        self.environment(\.fzDisplayMode, mode)
    }
}


extension View {
    func applyNormalMapShader() -> some View {
        self.visualEffect { content, proxy in
            content
                .layerEffect(ShaderLibrary.grayscaleNormalize(.float2(proxy.size), .float(0.0), .float(0.0), .float(1.0)), maxSampleOffset: CGSize(width: 4, height: 4))
                // .layerEffect(ShaderLibrary.customAA(.float2(proxy.size)), maxSampleOffset: .zero)
                .layerEffect(ShaderLibrary.genNormalMapEx(.float2(proxy.size), .float(1.0),),
                             maxSampleOffset: CGSize(width: 4, height: 4))
                /*
                .layerEffect(ShaderLibrary.genNormalMapEx2(.float2(proxy.size), .float(1.0),),
                             maxSampleOffset: CGSize(width: 4, height: 4))
                 */
        }
    }
}
