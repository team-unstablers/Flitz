//
//  Text.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import Foundation

extension Flitz {
    class Text: Element, ObservableObject {
        enum CodingKeys: String, CodingKey {
            case id, type, text, transform, zIndex
        }

        var type: ElementType { .text }
        
        @Published
        var id: UUID
        
        @Published
        var text: String
        
        @Published
        var transform: Transform
        
        @Published
        var zIndex: Int

        init(_ text: String) {
            self.id = UUID()
            self.text = text
            self.transform = Transform()
            self.zIndex = 0
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
            text = try container.decode(String.self, forKey: .text)
            transform = try container.decode(Transform.self, forKey: .transform)
            zIndex = try container.decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(type, forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encode(transform, forKey: .transform)
            try container.encode(zIndex, forKey: .zIndex)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(text)
            hasher.combine(transform)
            hasher.combine(zIndex)
        }
        
        static func == (lhs: Flitz.Text, rhs: Flitz.Text) -> Bool {
            lhs.id == rhs.id &&
            lhs.text == rhs.text &&
            lhs.transform == rhs.transform &&
            lhs.zIndex == rhs.zIndex
        }
    }
}

