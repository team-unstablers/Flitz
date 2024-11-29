//
//  Card.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import Foundation

struct FZSimpleCard: Codable, Identifiable {
    var id: String
    var title: String
    var created_at: String
    var updated_at: String
}

struct FZCard: Codable, Identifiable {
    var id: String
    var title: String
    var content: Flitz.Card
    var created_at: String
    var updated_at: String
}
