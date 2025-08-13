//
//  Flitz.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz {
    struct Renderer {
        @ViewBuilder
        static func renderer(for element: any Element, eventHandler: @escaping (FZTransformEvent) -> Void) -> some View {
            switch element {
            case let text as Flitz.Text:
                TextElementView(element: text, eventHandler: eventHandler)
            case let image as Flitz.Image:
                ImageElementView(element: image, eventHandler: eventHandler)
            default:
                EmptyView()
            }
        }
        
        @ViewBuilder
        static func editor(for element: any Element, dismissHandler: @escaping () -> Void) -> some View {
            switch element {
            case let text as Flitz.Text:
                TextElementEditorView(element: text, dismissHandler: dismissHandler)
            default:
                EmptyView()
            }
        }
    }
}

