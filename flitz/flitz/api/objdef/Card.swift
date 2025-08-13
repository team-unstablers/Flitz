//
//  Card.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

struct FZCardDistribution: Codable, Identifiable {
    var id: String
    var card: FZSimpleCard
    var user: FZUser
}

struct FZSimpleCard: Codable, Identifiable {
    var id: String
    var title: String
    var created_at: String
    var updated_at: String
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
