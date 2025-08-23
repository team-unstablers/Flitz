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
    
    var attachEditorHandler: ((Int) -> Void)? = nil
    
    var body: some View {
        ZStack {
            if asNormalMap {
                ZStack {
                    // Rectangle().fill(.black)
                    GeometryReader { innerGeom in
                        ForEach(0..<elements.count) { index in
                            Flitz.Renderer.renderer(for: elements[index]) { event in
                                handleTransformEvent(event, elementIndex: index)
                            }
                                .mode(.normalMap)
                                .id(elements[index].id)
                        }
                    }
                }
                .applyNormalMapShader()
            } else {
                GeometryReader { innerGeom in
                    ForEach(0..<elements.count, id: \.self) { index in
                        Flitz.Renderer.renderer(for: elements[index]) { event in
                            handleTransformEvent(event, elementIndex: index)
                        }
                            .id(elements[index].id)
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
                        .if(asNormalMap) { view in
                            view.applyNormalMapShader()
                                .blur(radius: 1.0)
                        }
                case .origin(let id, _):
                    if let image = assetsLoader.image(for: "fzcard:image:\(id)") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .if(asNormalMap) { view in
                                view.applyNormalMapShader()
                                    .blur(radius: 1.0)
                            }
                    } else {
                        Rectangle().fill(.white)
                    }
                }
            } else {
                Rectangle().fill([.gray, .blue, .red, .yellow, .green, .purple, .pink, .orange, .indigo, .mint].randomElement()!)
            }
        }
        .fixedSize()
        .clipped()
    }
    
    func handleTransformEvent(_ event: FZTransformEvent, elementIndex: Int) {
        if event == .edit {
            attachEditorHandler?(elementIndex)
        } else if event == .delete {
            elements.remove(at: elementIndex)
        } else if event == .zIndexChange {
            // move element to the end of the array
            let max = elements.map { $0.zIndex }.max() ?? 0
            elements[elementIndex].zIndex = max + 1
            
            let indices = elements.map { $0.zIndex }.sorted()
            elements.forEach {
                if let index = indices.firstIndex(of: $0.zIndex) {
                    $0.zIndex = index
                }
            }
        }
    }
}
