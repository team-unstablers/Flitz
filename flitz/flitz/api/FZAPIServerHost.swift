//
//  FZAPIServerHost.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZAPIServerHost: RawRepresentable, Codable {
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
    
    static let production = FZAPIServerHost(rawValue: "https://api-prod.flitz.cards")
    
#if DEBUG
    static let development = FZAPIServerHost(rawValue: "https://flitz-api-dev.internal.unstabler.pl")
    
    static let local = FZAPIServerHost(rawValue: "http://cheese-mbpr14.local:8000")
#endif
    
#if DEBUG
    static let `default` = Self.local
#else
    static let `default` = Self.production
#endif
}
