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
    
    
    class Card: Codable, ObservableObject, Hashable {
        enum CodingKeys: String, CodingKey {
            case schema_version, background, elements, properties
        }
        
        var schema_version: CardVersion
        
        var background: ImageSource?
        
        var elements: [any Element]
        var properties: [CardPropertyKey: String]
        
        init(version: CardVersion = .v1, background: ImageSource? = nil, elements: [any Element] = [], properties: [CardPropertyKey: String] = [:]) {
            self.schema_version = version
            self.background = background
            self.elements = elements
            self.properties = properties
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.schema_version = try container.decode(CardVersion.self, forKey: .schema_version)
            self.background = try container.decode(ImageSource?.self, forKey: .background)
            
            var elementsArray = try container.nestedUnkeyedContainer(forKey: .elements)
            var elements: [any Element] = []
            
            while !elementsArray.isAtEnd {
                let container = try elementsArray.decode(ElementTypeContainer.self)
                elements.append(container.element())
            }
            
            self.elements = elements
            
            // self.properties = try container.decode([CardPropertyKey: String].self, forKey: .properties)
            self.properties = [:]
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(schema_version, forKey: .schema_version)
            var elementsArray = container.nestedUnkeyedContainer(forKey: .elements)
            for element in elements {
                let container = ElementTypeContainer(element)
                try elementsArray.encode(container)
            }
            
            try container.encode(properties, forKey: .properties)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(schema_version)
            hasher.combine(background)
            
            for element in elements {
                hasher.combine(element)
            }
            
            hasher.combine(properties)
        }
        
        static func == (lhs: Flitz.Card, rhs: Flitz.Card) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }
}
