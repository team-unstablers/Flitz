//
//  FZCardViewSwiftUIRenderer.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/25/24.
//

import Foundation

import SwiftUI

class FZCardViewSwiftUICardRenderer: FZCardViewCardRenderer {
    func render(card: Flitz.Card) throws -> UIImage {
        var backgroundImage: UIImage? = nil
        
        if let backgroundSource = card.background {
            switch backgroundSource {
            case .uiImage(let image):
                backgroundImage = image
            default:
                break
            }
        }
        
        let view = CardCanvas(background: backgroundImage, elements: .constant(card.elements))
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        guard let image = renderer.uiImage else {
            throw FZCardViewError.renderFailed
        }
        
        return image
    }
    
    func renderNormalMap(card: Flitz.Card) throws -> UIImage {
        let view = CardCanvas(background: nil, elements: .constant(card.elements), asNormalMap: true)
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
