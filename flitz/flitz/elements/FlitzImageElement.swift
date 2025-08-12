//
//  Text.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import Foundation
import UIKit


extension Flitz {
    enum ImageSource: Hashable, Codable {
        case uiImage(UIImage)
        case origin(String, URL)
        
        enum CodingKeys: String, CodingKey {
            case id, public_url
        }
        
        var isLocal: Bool {
            if case .uiImage = self {
                return true
            }
            
            return false
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let id = try container.decode(String.self, forKey: .id)
            let public_url = try container.decode(URL.self, forKey: .public_url)
            
            self = .origin(id, public_url)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .uiImage(_):
                fatalError("assertion failed: 로컬 이미지는 서버에 먼저 업로드되어야 합니다")
            case .origin(let id, let url):
                try container.encode(id, forKey: .id)
                try container.encode(url, forKey: .public_url)
            }
        }
    }
    
    class Image: Element, ObservableObject {
        enum CodingKeys: String, CodingKey {
            case type, source, size, transform, zIndex
        }

        var type: ElementType { .image }
        
        @Published
        var source: ImageSource
        
        @Published
        var size: ElementSize

        @Published
        var transform: Transform
        
        @Published
        var zIndex: Int

        init(_ source: ImageSource, size: ElementSize) {
            self.source = source
            self.size = size
            self.transform = Transform()
            self.zIndex = 0
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            source = try container.decode(ImageSource.self, forKey: .source)
            size = try container.decode(ElementSize.self, forKey: .size)
            transform = try container.decode(Transform.self, forKey: .transform)
            zIndex = try container.decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(source, forKey: .source)
            try container.encode(size, forKey: .size)
            try container.encode(transform, forKey: .transform)
            try container.encode(zIndex, forKey: .zIndex)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(source)
            hasher.combine(size)
            hasher.combine(transform)
            hasher.combine(zIndex)
        }

        static func == (lhs: Flitz.Image, rhs: Flitz.Image) -> Bool {
            lhs.source == rhs.source &&
            lhs.size == rhs.size &&
            lhs.transform == rhs.transform &&
            lhs.zIndex == rhs.zIndex
        }
        
    }
}

