//
//  MessageComposeArea.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI
import PhotosUI

import BrightroomEngine
import BrightroomUI

struct MessageRequest {
    var text: String
    var images: [UIImage]
    
    init(text: String, images: [UIImage]) {
        self.text = text
        self.images = images
    }
}

struct EditableImageThumbnail: View {
    var editorContext: ImageEditorContext
    var image: UIImage
    
    var onSave: (() -> Void)? = nil
    
    @State
    var editorVisible = false

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
            .padding(4)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
            .onTapGesture {
                editorVisible = true
            }
            .sheet(isPresented: $editorVisible) {
                NavigationStack {
                    VStack {
                        SwiftUICropView(editingStack: editorContext.editingStack, isAutoApplyEditingStackEnabled: true)
                    }
                    .navigationTitle("이미지 자르기")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                editorContext.editingStack.revertEdit()
                                editorVisible = false
                                self.onSave?()
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("완료") {
                                editorVisible = false
                                self.onSave?()
                            }
                        }
                    }

                }
            }
    }
}

struct MessageComposeArea: View {
    @State
    private var text: String = ""
    
    var focused: FocusState<Bool>.Binding
    var onSend: ((MessageRequest) -> Void)?
    
    var isSending: Bool = false
    
    @State
    var selectedItems: [PhotosPickerItem] = []
    
    @State
    var editorContexts: [ImageEditorContext] = []
    
    @State
    var renderedImages: [UIImage] = []
    
    @State
    var editorIndex: Int? = nil
    
    
    var isEmpty: Bool {
        get {
            text.isEmpty && editorContexts.isEmpty
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 4 - editorContexts.count, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())

            }
                .buttonStyle(.plain)
                .disabled(editorContexts.count >= 4)
                .onChange(of: selectedItems) { _, newValue in
                    Task {
                        await self.loadImages()
                    }
                }
            
            VStack(alignment: .leading) {
                if !editorContexts.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<editorContexts.count, id: \.self) { index in
                                if index < renderedImages.count {
                                    EditableImageThumbnail(editorContext: editorContexts[index],
                                                           image: renderedImages[index]) {
                                        self.renderImages()
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                }
                TextField("메시지를 입력하세요", text: $text, axis: .vertical)
                    .lineLimit(1...3)
                // .disabled(isSending)
                    .focused(focused)
                    .onSubmit {
                        sendMessage()
                }
            }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            
           
            Button {
                sendMessage()
            } label: {
                if isSending {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }
            }
            .padding(12)
            .background(isEmpty || isSending ? Color.gray : Color.blue)
            .clipShape(Circle())
            .buttonStyle(.plain)
            .disabled(isEmpty || isSending)
            .focusable(false)
            .padding(.bottom, 2)
        }
        .padding(.vertical)
        .padding(.horizontal, 8)

    }
    
    private func loadImages() async {
        // images = []
        
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let editorContext = try? await ImageEditorContext(from: data) {
                editorContexts.append(editorContext)
            }
            
            if editorContexts.count >= 4 {
                break
            }
        }
        
        selectedItems = []
        self.renderImages()
    }
    
    private func sendMessage() {
        guard !isEmpty else { return }
        let message = text
        text = ""
        
        self.renderImages()
        
        let request = MessageRequest(text: message, images: renderedImages)
        onSend?(request)
        
        selectedItems = []
        editorContexts = []
    }
    
    private func renderImages() {
        renderedImages = []
        
        for context in editorContexts {
            do {
                try context.render()
                
                if let image = context.rendered?.uiImage {
                    renderedImages.append(image)
                }
            } catch {
                print("Failed to render image: \(error)")
            }
        }
    }
}

#Preview {
    MessageComposeArea(focused: FocusState<Bool>().projectedValue)
}
