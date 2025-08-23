//
//  AssetsLoader.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 12/1/24.
//

import Foundation
import Combine

import UIKit

import Alamofire
import AlamofireImage

class AssetsLoader {
    static let global = AssetsLoader()
    
    let cacheStorage = ImageCacheStorage.shared

    init() {
    }
    
    func resolveAll(from card: Flitz.Card) async throws {
        await withThrowingTaskGroup { group in
            if let background = card.background {
                group.addTask {
                    try await self.resolve(image: background)
                }
            }
            
            for asset in card.collectImageAssets() {
                group.addTask {
                    try await self.resolve(image: asset)
                }
            }
        }
    }
    
    func resolve(image source: Flitz.ImageSource) async throws {
        guard case .origin(let id, let url) = source else {
            return
        }
        
        let identifier = "fzcard:image:\(id)"
        _ = await cacheStorage.resolve(by: identifier, origin: url)
    }
    
    @available(*, deprecated, message: "CachedAsyncImage를 대신 사용하십시오.")
    func image(for id: String) -> UIImage? {
        guard let entry = cacheStorage.resolve(by: id) else {
            return nil
        }
        
        return UIImage(contentsOfFile: entry.url.path())
    }
    
}
