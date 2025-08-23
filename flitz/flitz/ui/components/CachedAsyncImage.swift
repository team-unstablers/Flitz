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
                        Task {
                            await loadImage()
                        }
                    }
            } else if loadFailed && retryCount < maxRetries {
                placeholder()
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                            if loadFailed && retryCount < maxRetries {
                                Task {
                                    await loadImage()
                                }
                            }
                        }
                    }
            } else {
                placeholder()
            }
        }
    }
    
    @MainActor
    private func loadImage() async {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        hasTriedLoading = true
        loadFailed = false
        
        defer {
            isLoading = false
        }
        
        let cacheStorage = ImageCacheStorage.shared
        let identifier = identifier ?? "rawurl:\(url.hashValue)"
        
        guard let cacheEntry = await cacheStorage.resolve(by: identifier, origin: url) else {
            self.retryCount += 1
            return
        }
        
        image = UIImage(contentsOfFile: cacheEntry.url.path())
        
    }
}

