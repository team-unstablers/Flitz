//
//  CardCanvas.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct FlitzCard {
    static let size: CGSize = CGSize(width: 550, height: 850)
}

struct CardCanvas: View {
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader

    var background: Flitz.ImageSource?
    
    @Binding
    var elements: [any Flitz.Element]
    
    var asNormalMap: Bool = false
    
    var body: some View {
        ZStack {
            if asNormalMap {
                ZStack {
                    Rectangle().fill(.black)
                    GeometryReader { innerGeom in
                        ForEach(0..<elements.count, id: \.self) { index in
                            Flitz.Renderer.renderer(for: elements[index])
                                .mode(.normalMap)
                        }
                    }
                }
                .applyNormalMapShader()
            } else {
                GeometryReader { innerGeom in
                    ForEach(0..<elements.count, id: \.self) { index in
                        Flitz.Renderer.renderer(for: elements[index])
                    }
                }
            }
        }
        .frame(width: FlitzCard.size.width, height: FlitzCard.size.height)
        .background {
            if let background = background {
                switch background {
                case .uiImage(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                case .origin(let id, _):
                    if let image = assetsLoader.images[id] {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle().fill(.white)
                    }
                }
            } else {
                Rectangle().fill([.gray, .blue, .red].randomElement()!)
            }
        }
        .fixedSize()
        .clipped()
    }
}
