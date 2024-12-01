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
    
    public protocol EditorView: View {
        associatedtype Element: Flitz.Element
        
        var element: Element { get }
        
        init(element: Element)
    }
    
    enum DisplayMode {
        case `default`
        case normalMap
        case editor
    }
    
    public struct ElementView<Element: Flitz.Element,
                              Renderer: RendererView,
                              NormalMapRenderer: NormalMapRendererView,
                              Editor: EditorView>: View
    where Renderer.Element == Element,
          NormalMapRenderer.Element == Element,
          Editor.Element == Element
    {
        @Environment(\.fzDisplayMode)
        private var displayMode: DisplayMode
        
        @ObservedObject
        var element: Element
        
        @State
        var delta: Flitz.Transform = .zero
        
        var body: some View {
            switch displayMode {
            case .default:
                Renderer(element: element)
                    .applyFZTransform(element.transform, delta: delta, editable: true)
            case .normalMap:
                NormalMapRenderer(element: element)
                    .applyFZTransform(element.transform, delta: delta)
            case .editor:
                Editor(element: element)
            }
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
                // .layerEffect(ShaderLibrary.customAA(.float2(proxy.size)), maxSampleOffset: .zero)
                .layerEffect(ShaderLibrary.genNormalMapEx(.float2(proxy.size), .float(1.0)),
                             maxSampleOffset: CGSize(width: 4, height: 4))
        }
    }
}
