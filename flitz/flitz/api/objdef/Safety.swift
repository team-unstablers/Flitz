//
//  Safety.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/15/25.
//

import Foundation

struct FZUserBlock: Codable, Identifiable {
    let id: String
    let blocked_user: FZUser
}

struct FZContactsTriggerEnabled: Codable {
    let is_enabled: Bool
}

struct FZContactsTrigger: Codable {
    let id: String
    let phone_number_hashed: String
}
