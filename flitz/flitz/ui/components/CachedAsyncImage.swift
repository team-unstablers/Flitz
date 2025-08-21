//
//  CachedAsyncImage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/8/25.
//

import SwiftUI
import Combine
import AlamofireImage
import Alamofire

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let identifier: String?
    let content: (SwiftUI.Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var hasTriedLoading = false
    @State private var loadFailed = false
    @State private var retryCount = 0
    @State private var loadingTask: DataRequest?
    
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 2.0
    
    init(
        url: URL?,
        identifier: String? = nil,
        @ViewBuilder content: @escaping (SwiftUI.Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.identifier = identifier
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(SwiftUI.Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else if !hasTriedLoading {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            } else if loadFailed && retryCount < maxRetries {
                placeholder()
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                            if loadFailed && retryCount < maxRetries {
                                loadImage()
                            }
                        }
                    }
            } else {
                placeholder()
            }
        }
        .onDisappear {
            loadingTask?.cancel()
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        hasTriedLoading = true
        loadFailed = false
        
        let imageCache = ImageCacheManager.shared.imageCache
        
        if let cachedImage = imageCache.image(for: URLRequest(url: url), withIdentifier: self.identifier) {
            self.image = cachedImage
            self.isLoading = false
            self.loadFailed = false
            return
        }
        
        loadingTask = AF.request(url)
            .validate()
            .responseImage(imageScale: UIScreen.main.scale) { response in
                isLoading = false
                
                switch response.result {
                case .success(let loadedImage):
                    imageCache.add(loadedImage, for: URLRequest(url: url), withIdentifier: self.identifier)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.image = loadedImage
                    }
                    self.loadFailed = false
                    self.retryCount = 0
                    
                case .failure:
                    self.loadFailed = true
                    self.retryCount += 1
                }
            }
    }
}

