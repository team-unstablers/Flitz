//
//  MessagingArgs.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/23/25.
//

import Foundation

struct FlagConversationReason: RawRepresentable, Codable, Equatable, Hashable {
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    static let offensive = Self.init(rawValue: "OFFENSIVE")
    static let pornographic = Self.init(rawValue: "PORNOGRAPHIC")
    static let impersonation = Self.init(rawValue: "IMPERSONATION")
    static let illegalContents = Self.init(rawValue: "ILLEGAL_CONTENTS")
    static let minor = Self.init(rawValue: "MINOR")
                                              
}

struct FlagConversationArgs: Codable {
    let message: String?
    
    let reason: [FlagConversationReason]
    let user_description: String?
}
