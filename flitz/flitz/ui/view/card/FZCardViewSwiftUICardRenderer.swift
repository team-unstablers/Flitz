//
//  FZCardViewSwiftUIRenderer.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation

import SwiftUI

class FZCardViewSwiftUICardRenderer: FZCardViewCardRenderer {
    
    @ViewBuilder
    private func buildView(card: Flitz.Card, options: FZCardViewCardRendererOptions) -> some View {
        CardCanvas(background: card.background, elements: .constant(card.elements), asNormalMap: options.contains(.renderNormalMap))
            .if(options.contains(.renderBlurry)) {
                $0
                    .compositingGroup()
                    .blur(radius: 24)
            }
    }
    
    func render(card: Flitz.Card, options: FZCardViewCardRendererOptions) throws -> UIImage {
        let view = buildView(card: card, options: options)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        guard let image = renderer.uiImage else {
            throw FZCardViewError.renderFailed
        }
        
        return image
    }
}

extension FZCardViewCardRenderer {
    static func swiftUI() -> FZCardViewCardRenderer {
        return FZCardViewSwiftUICardRenderer()
    }
}
