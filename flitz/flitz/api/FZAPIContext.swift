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
            var context = try decoder.decode(FZAPIContext.self, from: data)
            guard context.valid() else {
                return FZAPIContext()
            }
            
            return context
        } catch {
            return FZAPIContext()
        }
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "FZAPIContext")
    }
    
    var host: FZAPIServerHost = .default
    var token: String?
    
    var id: String?
    
    init() {
        
    }
    
    mutating func valid() -> Bool {
        // TODO: decode JWT
        guard let token = token else {
            return false
        }
        
        let components = token.split(separator: ".")
        guard components.count == 3 else {
            return false
        }
        
        let payload = components[1]
        guard let payloadData = Data(base64Encoded: String(payload).paddedBase64String) else {
            return false
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: payloadData, options: [])
            guard let dict = json as? [String: Any] else {
                return false
            }
            
            /*
            // Check for expiration
            if let exp = dict["exp"] as? TimeInterval {
                let expirationDate = Date(timeIntervalSince1970: exp)
                return expirationDate > Date()
            }
             */
            
            guard let id = dict["sub"] as? String,
                  let flitzOptions = dict["x-flitz-options"] as? String,
                  flitzOptions == "--with-love"
            else {
                return false
            }
            
            self.id = id
            
            return true
        } catch {
            print(error)
            return false
        }
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
