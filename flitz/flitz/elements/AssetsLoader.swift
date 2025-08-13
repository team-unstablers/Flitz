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

class AssetsLoader: ObservableObject {
    static let global = AssetsLoader()
    
    @Published
    private(set) public var images: [String: UIImage] = [:]
    
    init() {
    }
    
    func resolveAll(from card: Flitz.Card) async throws {
        if let background = card.background {
            try await self.resolve(image: background)
        }
        
        for asset in card.collectImageAssets() {
            try await self.resolve(image: asset)
        }
    }
    
    func resolve(image source: Flitz.ImageSource) async throws {
        guard case .origin(let id, let url) = source else {
            return
        }

        let response = await AF.request(url)
            .serializingImage(imageScale: 1)
            .response
        
        let image = try response.result.get()
        
        DispatchQueue.main.async {
            self.images[id] = image
        }
    }
    
    func image(for id: String) -> UIImage? {
        return images[id]
    }
    
}
