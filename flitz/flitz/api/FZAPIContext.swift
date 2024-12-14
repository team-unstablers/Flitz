//
//  FZAPIContext.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZAPIContext: Codable {
    enum CodingKeys: String, CodingKey {
#if DEBUG
        case host
#endif
        case token
    }
    
    static func load() -> FZAPIContext {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "FZAPIContext") else {
            return FZAPIContext()
        }
        
        do {
            return try decoder.decode(FZAPIContext.self, from: data)
        } catch {
            return FZAPIContext()
        }
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "FZAPIContext")
    }
    
    var host: FZAPIServerHost = .default
    var token: String?
    
    init() {
        
    }
    
    func save() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        
        UserDefaults.standard.set(data, forKey: "FZAPIContext")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
#if DEBUG
        host = try container.decode(FZAPIServerHost.self, forKey: .host)
#endif
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
#if DEBUG
        try container.encode(host, forKey: .host)
#endif
        if let token {
            try container.encode(token, forKey: .token)
        }
    }
    
}
