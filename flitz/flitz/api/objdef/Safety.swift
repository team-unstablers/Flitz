//
//  Safety.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import Foundation

struct FZContactsTriggerEnabled: Codable {
    let is_enabled: Bool
}

struct FZContactsTrigger: Codable {
    let id: String
    let phone_number_hashed: String
}
