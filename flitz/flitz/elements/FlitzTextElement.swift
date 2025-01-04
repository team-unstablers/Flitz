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
            case type, text, transform
        }

        var type: ElementType { .text }
        
        @Published
        var text: String
        
        @Published
        var transform: Transform

        init(_ text: String) {
            self.text = text
            self.transform = Transform()
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decode(String.self, forKey: .text)
            transform = try container.decode(Transform.self, forKey: .transform)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encode(transform, forKey: .transform)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(transform)
        }
        
        static func == (lhs: Flitz.Text, rhs: Flitz.Text) -> Bool {
            lhs.text == rhs.text &&
            lhs.transform == rhs.transform
        }
    }
}

