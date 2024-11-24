//
//  Text.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import Foundation
import UIKit

extension Flitz {
    enum ImageSource: Hashable {
        case uiImage(UIImage)
        case localURL(URL)
        case origin(URL)
    }
    
    class Image: Element, ObservableObject {
        enum CodingKeys: String, CodingKey {
            case type, source, size, transform
        }

        var type: ElementType { .text }
        
        @Published
        var source: ImageSource
        
        @Published
        var size: ElementSize

        @Published
        var transform: Transform

        init(_ source: ImageSource, size: ElementSize) {
            self.source = source
            self.size = size
            self.transform = Transform()
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // source = try container.decode(URL.self, forKey: .source)
            source = .uiImage(UIImage())
            size = try container.decode(ElementSize.self, forKey: .size)
            transform = try container.decode(Transform.self, forKey: .transform)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            // try container.encode(source, forKey: .source)
            try container.encode(size, forKey: .size)
            try container.encode(transform, forKey: .transform)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(source)
            hasher.combine(size)
            hasher.combine(transform)
        }

        static func == (lhs: Flitz.Image, rhs: Flitz.Image) -> Bool {
            lhs.source == rhs.source &&
            lhs.size == rhs.size &&
            lhs.transform == rhs.transform
        }
        
    }
}

