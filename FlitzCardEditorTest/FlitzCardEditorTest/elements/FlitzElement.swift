//
//  FlitzElement.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/23/24.
//

import Foundation

extension Flitz {
    struct ElementType: RawRepresentable, Codable, Hashable {
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
        
        static let text = ElementType(rawValue: "text")
        static let image = ElementType(rawValue: "image")
    }
    
    struct ElementSize: Codable {
        var width: Double
        var height: Double
    }
    
    struct Position: Codable {
        static let zero = Position(x: 0, y: 0)
        static let center = Position(x: 0.5, y: 0.5)
        
        var x: Double
        var y: Double
    }
    
    class Transform: Codable, ObservableObject {
        @Published
        var position: Position
        
        @Published
        var scale: Double
        
        // only supports 2D rotation
        @Published
        var rotation: Double
        
        init(position: Position = .center, scale: Double = 1, rotation: Double = 0) {
            self.position = position
            self.scale = scale
            self.rotation = rotation
        }
        
        enum CodingKeys: String, CodingKey {
            case position, scale, rotation
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            position = try container.decode(Position.self, forKey: .position)
            scale = try container.decode(Double.self, forKey: .scale)
            rotation = try container.decode(Double.self, forKey: .rotation)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(position, forKey: .position)
            try container.encode(scale, forKey: .scale)
            try container.encode(rotation, forKey: .rotation)
        }
    }

    protocol Element: Codable, ObservableObject {
        var type: ElementType { get }
        var transform: Transform { get set }
    }
    

    struct ElementTypeContainer: Codable {
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        let type: ElementType
        
        var text: Flitz.Text?
        var image: Flitz.Image?
        
        init(_ element: any Element) {
            self.type = element.type
            
            switch element {
            case let text as Flitz.Text:
                self.text = text
            case let image as Flitz.Image:
                self.image = image
            default:
                fatalError("unsupported element type")
            }
        }
        
        func encode(to encoder: Encoder) throws {
            switch type {
            case .text:
                try text!.encode(to: encoder)
            case .image:
                try image!.encode(to: encoder)
            default:
                fatalError("unsupported element type")
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(ElementType.self, forKey: .type)
            
            switch type {
            case .text:
                text = try Flitz.Text(from: decoder)
            case .image:
                image = try Flitz.Image(from: decoder)
            default:
                fatalError("unsupported element type")
            }
        }
        
        func element() -> any Element {
            switch type {
            case .text:
                return text!
            case .image:
                return image!
            default:
                fatalError("unsupported element type")
            }
        }
        
        func typedElement<T: Element>(as type: T.Type) throws -> T {
            switch type {
            case is Flitz.Text.Type:
                return text as! T
            case is Flitz.Image.Type:
                return image as! T
            default:
                fatalError("unsupported element type")
            }
        }
    }
    

}

