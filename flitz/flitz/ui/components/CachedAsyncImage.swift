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
    let content: (SwiftUI.Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var loadingTask: DataRequest?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (SwiftUI.Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(SwiftUI.Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .onDisappear {
            loadingTask?.cancel()
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        let imageCache = ImageCacheManager.shared.imageCache
        
        if let cachedImage = imageCache.image(for: URLRequest(url: url), withIdentifier: nil) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        loadingTask = AF.request(url)
            .validate()
            .responseImage(imageScale: UIScreen.main.scale) { response in
                isLoading = false
                
                if case .success(let loadedImage) = response.result {
                    imageCache.add(loadedImage, for: URLRequest(url: url), withIdentifier: nil)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.image = loadedImage
                    }
                }
            }
    }
}

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    let imageCache: ImageRequestCache
    let imageDownloader: ImageDownloader
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        let memoryCapacity = 100 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        configuration.urlCache = cache
        
        imageCache = AutoPurgingImageCache(
            memoryCapacity: UInt64(memoryCapacity),
            preferredMemoryUsageAfterPurge: UInt64(memoryCapacity / 2)
        )
        
        imageDownloader = ImageDownloader(
            configuration: configuration,
            imageCache: imageCache
        )
    }
    
    func prefetchImages(urls: [URL]) {
        let requests = urls.map { URLRequest(url: $0) }
        imageDownloader.download(requests)
    }
}
