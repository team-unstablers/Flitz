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
                TextElementView(element: text)
            case let image as Flitz.Image:
                EmptyView()
                // ImageRenderer(element: image)
            default:
                EmptyView()
            }
        }
    }
}

