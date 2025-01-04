//
//  CardEditor.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct CardEditorInternal: View {
    @ObservedObject
    var card: Flitz.Card
    
    @State
    var backgroundImage: UIImage?

    @State
    var showImagePicker: Bool = false
    
    @State
    var showBackgroundImagePicker: Bool = false

    @State
    var selectedImage: UIImage?
    
    
    var body: some View {
        VStack {
            HStack {
                Button("Background") {
                    showBackgroundImagePicker = true
                }
                Button("Text") {
                    card.elements.append(Flitz.Text("hello"))
                }
                Button("Image") {
                    showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                if let image = selectedImage {
                    card.elements.append(
                        Flitz.Image(.uiImage(image),
                                    size: .init(width: image.size.width,
                                                height: image.size.height))
                    )
                }
            }) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showBackgroundImagePicker, onDismiss: {
                if let image = backgroundImage {
                    self.backgroundImage = image
                }
            }) {
                ImagePicker(image: $backgroundImage)
            }
            
            GeometryReader { geom in
                ZStack {
                    CardCanvas(background: backgroundImage, elements: $card.elements)
                        .aspectScale(basedOn: FlitzCard.size, to: geom.size)
                        .onAppear {
                            print(geom.size.width / 550)
                        }
                }
                    .frame(width: geom.size.width, height: geom.size.height)
                    .background(.black)
            }
        }
    }
}

/*
#Preview {
    @State
    @Previewable
    var elements: [any Flitz.Element] = []
    
    CardEditorInternal(backgroundImage: .constant(nil), elements: $elements)
}
*/
