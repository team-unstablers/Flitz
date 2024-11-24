//
//  TExt.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    struct ImageRenderer: RendererView {
        @ObservedObject
        var element: Flitz.Image
        
        var body: some View {
            switch element.source {
            case .uiImage(let image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: element.size.width, height: element.size.height)
            default:
                EmptyView()
            }
        }
        
        @ViewBuilder
        var normalMapBody: some View {
            switch element.source {
            case .uiImage(let image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: element.size.width, height: element.size.height)
                    .blur(radius: 1.5)
            default:
                EmptyView()
                    .frame(width: element.size.width, height: element.size.height)
            }
        }
    }
}

