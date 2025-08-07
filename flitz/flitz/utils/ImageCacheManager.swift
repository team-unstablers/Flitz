//
//  ImageCacheManager.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/8/25.
//

import Foundation
import AlamofireImage
import Alamofire

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