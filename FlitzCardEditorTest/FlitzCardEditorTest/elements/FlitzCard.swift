//
//  FlitzCard.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import Foundation

extension Flitz {
    struct CardVersion: RawRepresentable, Codable, Hashable {
        var rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }

        static let v1 = CardVersion(rawValue: "v1")
    }
    
    struct CardPropertyKey: RawRepresentable, Codable, Hashable {
        var rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
        
        static let cardSize = CardVersion(rawValue: "card_size")
    }
    
    typealias card_id_t = UUID
    
    
    struct Card: Codable {
        enum CodingKeys: String, CodingKey {
            case id, version, elements, properties
        }
        
        var id: card_id_t?
        var version: CardVersion
        
        var elements: [any Element]
        var properties: [CardPropertyKey: String]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decodeIfPresent(card_id_t.self, forKey: .id)
            self.version = try container.decode(CardVersion.self, forKey: .version)
            self.properties = try container.decode([CardPropertyKey: String].self, forKey: .properties)
            
            var elementsArray = try container.nestedUnkeyedContainer(forKey: .elements)
            var elements: [any Element] = []
            
            while !elementsArray.isAtEnd {
                let container = try elementsArray.decode(ElementTypeContainer.self)
                elements.append(container.element())
            }
            
            self.elements = elements
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(version, forKey: .version)
            var elementsArray = container.nestedUnkeyedContainer(forKey: .elements)
            for element in elements {
                let container = ElementTypeContainer(element)
                try elementsArray.encode(container)
            }
            
            try container.encode(properties, forKey: .properties)
        }
    }
}
