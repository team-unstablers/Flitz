//
//  Flitz.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct Flitz {
    struct Renderer {
        @ViewBuilder
        static func renderer(for element: any Element) -> some View {
            switch element {
            case let text as Flitz.Text:
                TextRenderer(element: text)
            case let image as Flitz.Image:
                ImageRenderer(element: image)
            default:
                EmptyView()
            }
        }
        
        @ViewBuilder
        static func normalMappedRenderer(for element: any Element) -> some View {
            switch element {
            case let text as Flitz.Text:
                DraggableView(transform: text.transform) {
                    TextRenderer(element: text)
                        .normalMapBody
                }
            case let image as Flitz.Image:
                DraggableView(transform: image.transform) {
                    ImageRenderer(element: image)
                        .normalMapBody
                }
            default:
                EmptyView()
            }
        }
        
        @ViewBuilder
        static func coordinatedRenderer(for element: any Element) -> some View {
            switch element {
            case let text as Flitz.Text:
                DraggableView(transform: text.transform) {
                    TextRenderer(element: text)
                        // .elementDebugInfo(of: text)
                }
            case let image as Flitz.Image:
                DraggableView(transform: image.transform) {
                    ImageRenderer(element: image)
                        // .elementDebugInfo(of: image)
                }

            default:
                EmptyView()
            }
        }
    }
}
