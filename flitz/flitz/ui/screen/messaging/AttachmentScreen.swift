//
//  AttachmentScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/8/25.
//

import SwiftUI
import Combine
import Photos


@MainActor
class AttachmentViewModel: ObservableObject {
    @Published var conversationId: String
    @Published var attachmentId: String
    @Published var attachment: DirectMessageAttachment?
    
    private var apiClient: FZAPIClient?

    init(conversationId: String, attachmentId: String) {
        self.conversationId = conversationId
        self.attachmentId = attachmentId
    }
    
    func configure(with apiClient: FZAPIClient) {
        self.apiClient = apiClient
        
        Task {
            await loadAttachment()
        }
    }
    
    private func loadAttachment() async {
        do {
            self.attachment = try await apiClient?.attachment(conversationId: conversationId, id: attachmentId)
        } catch {
            print("[AttachmentViewModel] Failed to load attachment: \(error)")
        }
    }
}


struct AttachmentScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel: AttachmentViewModel
    
    @State
    var toolbarVisible: Bool = true
    
    init(conversationId: String, attachmentId: String) {
        _viewModel = StateObject(wrappedValue: AttachmentViewModel(conversationId: conversationId, attachmentId: attachmentId))
    }
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if let attachment = viewModel.attachment {
                    CachedAsyncImage(
                        url: URL(string: attachment.public_url),
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                        },
                        placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                    )
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Rectangle()
                    .fill(Color.black.opacity(0.001))
                    // .ignoresSafeArea()
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                withAnimation(.spring()) {
                                    toolbarVisible = false
                                }
                                
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 0.25), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                withAnimation(.spring()) {
                                    if scale < 1 {
                                        scale = 1
                                        offset = .zero
                                    }
                                }
                            }
                            .simultaneously(with:
                                                DragGesture()
                                .onChanged { value in
                                    if scale > 1 {
                                        withAnimation(.spring()) {
                                            toolbarVisible = false
                                        }

                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    
                                    // 화면 밖으로 나가지 않도록 제한
                                    withAnimation(.spring()) {
                                        let maxX = (geometry.size.width * (scale - 1)) / 2
                                        let maxY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        offset.width = min(max(offset.width, -maxX), maxX)
                                        offset.height = min(max(offset.height, -maxY), maxY)
                                        lastOffset = offset
                                    }
                                }
                                           )
                    )
                    .onTapGesture(count: 1) {
                        withAnimation(.spring()) {
                            toolbarVisible = !toolbarVisible
                        }
                    }
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            toolbarVisible = false
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2
                            }
                        }
                    }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        /*
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        saveImageToPhotos()
                    } label: {
                        Text(NSLocalizedString("ui.messaging.attachment.save", comment: "사진 앱에 저장"))
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        // .foregroundColor()
                }
            }
        }
         */
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarVisibility(toolbarVisible ? .visible : .hidden, for: .navigationBar)
        .statusBar(hidden: scale > 1)
        .ignoresSafeArea()
        .onAppear {
            viewModel.configure(with: appState.client)
        }
    }
    
    private func saveImageToPhotos() {
        guard let attachment = viewModel.attachment,
              let url = URL(string: attachment.public_url) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return }
                
                await MainActor.run {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }
}
    
