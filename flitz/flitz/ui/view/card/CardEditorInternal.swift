//
//  CardEditor.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import SwiftUI

struct CardEditorButton: View {
    var icon: String
    var description: String
    
    var handler: (() -> Void)? = nil
    
    @State
    var isHovered: Bool = false
    
    var body: some View {
        Button {
            handler?()
        } label: {
            VStack(spacing: 0) {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)
            .background(.black.opacity(0.6))
            .cornerRadius(14)
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation {
                isHovered = true
            }
        } onPressingChanged: { pressing in
            withAnimation {
                isHovered = pressing
            }
        }
        .overlay {
            if isHovered {
                Text(description)
                    .font(.system(size: 12))
                    .fixedSize()
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .offset(y: 42)
            }
        }
    }
}

struct CardEditorInternal: View {
    @ObservedObject
    var card: Flitz.Card
    
    @Binding
    var isElementEditorPresented: Bool
    
    @State
    var backgroundImage: UIImage?

    @State
    var showImagePicker: Bool = false
    
    @State
    var showBackgroundImagePicker: Bool = false

    @State
    var selectedImage: UIImage?
    
    @State
    var currentElementIndex: Int? = nil
    
    
    var toolbar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack {
                    CardEditorButton(icon: "CardEditorFrameButtonIcon", description: NSLocalizedString("ui.card.editor.tool.background", comment: "배경 이미지")) {
                        showBackgroundImagePicker = true
                    }
                }
                Spacer()
                HStack {
                    CardEditorButton(icon: "CardEditorTextButtonIcon", description: NSLocalizedString("ui.card.editor.tool.add_text", comment: "텍스트 추가")) {
                        card.elements.append(Flitz.Text("텍스트 입력"))
                    }
                    CardEditorButton(icon: "CardEditorStickerButtonIcon", description: NSLocalizedString("ui.card.editor.tool.add_sticker", comment: "스티커 추가")) {
                        showImagePicker = true
                    }
                }
            }
            .padding(16)
            
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { geom in
                let viewportSize = CGSize(width: geom.size.width,
                                          height: (FlitzCard.size.height * geom.size.width) / FlitzCard.size.width)
                
                ZStack {
                    CardCanvas(background: card.background, elements: $card.elements, attachEditorHandler: { index in
                        guard card.elements[index].type == .text else {
                            return
                        }
                        
                        currentElementIndex = index
                    })
                        .aspectScale(basedOn: FlitzCard.size, to: geom.size)
                        .onChange(of: currentElementIndex) { _, newValue in
                            if newValue == nil {
                                isElementEditorPresented = false
                            } else {
                                isElementEditorPresented = true
                            }
                        }

                    
                    if let index = currentElementIndex {
                        let element = card.elements[index]
                        
                        Flitz.Renderer.editor(for: element) {
                            currentElementIndex = nil
                        }
                            .keyboardPadding()
                    } else {
                        self.toolbar
                            .frame(width: viewportSize.width, height: viewportSize.height)
                    }
                }
                    .frame(width: geom.size.width, height: geom.size.height)
                    .background(.black)
            }
        }
        .font(.none)
        .ignoresSafeArea(.keyboard)
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
                card.background = .uiImage(image)
            }
        }) {
            ImagePicker(image: $backgroundImage)
        }
    }
}

#Preview {
    @State
    @Previewable
    var card = Flitz.Card()
    
    @State
    @Previewable
    var isElementEditorPresented = false
    
    CardEditorInternal(card: card, isElementEditorPresented: $isElementEditorPresented)
}
