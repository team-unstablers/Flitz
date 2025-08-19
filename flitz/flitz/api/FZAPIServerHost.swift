//
//  FZAPIServerHost.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZAPIServerHost: RawRepresentable, Codable, Hashable {
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
    
    static var allCases: [FZAPIServerHost] {
#if DEBUG
        return [.production, .development, .local]
#else
        return [.production]
#endif
    }
    
    static let production = FZAPIServerHost(rawValue: "https://prod.api.flitz.cards")
    
#if DEBUG
    static let development = FZAPIServerHost(rawValue: "https://api-dev.flitz.cards")
    static let local = FZAPIServerHost(rawValue: "http://cheese-mbpr14.local:8000")
#endif
    
#if DEBUG
    static let `default` = Self.development
#else
    static let `default` = Self.production
#endif
    
    
    var description: String {
        switch self {
        case .default:
            return "기본값"
        case .production:
            return "프로덕션"
#if DEBUG
        case .development:
            return "개발"
        case .local:
            return "로컬"
#endif
        default:
            return "임의 설정"
        }
    }
}
