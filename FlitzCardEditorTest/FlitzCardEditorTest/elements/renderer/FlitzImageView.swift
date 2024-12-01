//
//  TExt.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

extension Flitz.Renderer {
    struct Image {
        struct ImageRendererView: RendererView {
            @Environment(\.fzAssetsLoader)
            var assetsLoader: AssetsLoader
            
            @ObservedObject
            var element: Flitz.Image
            
            init(element: Flitz.Image) {
                self.element = element
            }
            
            var body: some View {
                switch element.source {
                case .uiImage(let image):
                    SwiftUI.Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: element.size.width, height: element.size.height)
                case .origin(let id, _):
                    if let image = assetsLoader.images[id] {
                        SwiftUI.Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: element.size.width, height: element.size.height)
                    }
                }
            }
        }
        
        struct ImageNormalMapRendererView: NormalMapRendererView {
            @Environment(\.fzAssetsLoader)
            var assetsLoader: AssetsLoader

            @ObservedObject
            var element: Flitz.Image
            
            init(element: Flitz.Image) {
                self.element = element
            }

            var body: some View {
                switch element.source {
                case .uiImage(let image):
                    SwiftUI.Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: element.size.width, height: element.size.height)
                        .blur(radius: 1.5)
                case .origin(let id, _):
                    if let image = assetsLoader.images[id] {
                        SwiftUI.Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: element.size.width, height: element.size.height)
                    }
                }
            }
        }
        
        struct ImageEditorView: EditorView {
            @ObservedObject
            var element: Flitz.Image
            
            var body: some View {
                EmptyView()
            }
        }
    }
    
    typealias ImageElementView = ElementView<Flitz.Image,
                                             Image.ImageRendererView,
                                             Image.ImageNormalMapRendererView,
                                             Image.ImageEditorView>
}

