//
//  Card.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

struct FZCardDistributionRevealPhase: RawRepresentable, Codable, Equatable {
    var rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(Int.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    static func ==(lhs: FZCardDistributionRevealPhase, rhs: FZCardDistributionRevealPhase) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static let hidden = Self.init(rawValue: 0)
    static let blurry = Self.init(rawValue: 1)
    static let UNUSED_blurryLesser = Self.init(rawValue: 2)
    static let revealed = Self.init(rawValue: 3)
}

struct FZCardDistribution: Codable, Identifiable {
    var id: String
    var card: FZCard
    var user: FZUser
    var reveal_phase: FZCardDistributionRevealPhase
}

struct FZCardFavoriteItem: Codable, Identifiable {
    var id: String
    var card: FZCard
}

struct FZCard: Codable, Identifiable {
    var id: String
    var title: String
    var user: FZUser?
    var content: Flitz.Card
    var created_at: String
    var updated_at: String
}


struct FZCardAssetReference: Codable, Identifiable {
    var id: String
    var public_url: String
}
