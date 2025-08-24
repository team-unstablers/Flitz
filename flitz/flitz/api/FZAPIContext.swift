//
//  FZAPIContext.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZSecAPIContext: Codable {
    static let logger = createFZOSLogger("FZSecAPIContext")
    
    private static let KEYCHAIN_SERVICE = "pl.unstabler.flitz.api.seccontext"
    private static let KEYCHAIN_ACCOUNT_DEFAULT = "flitzuser"
    
    enum CodingKeys: String, CodingKey {
#if DEBUG
        case host
#endif
        case token
        case refreshToken
    }
    
#if DEBUG
    var host: FZAPIServerHost = .default
#else
    let host: FZAPIServerHost = .default
#endif
    
    var token: String?
    var refreshToken: String?
    
    private var payload: [String: Any]?
    
    var id: String? {
        guard let payload = payload else {
            return nil
        }
        
        return payload["sub"] as? String
    }
    
    var expired: Bool {
        guard let payload = payload,
              let exp = payload["exp"] as? TimeInterval
        else {
            return true
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate <= Date()
    }
    
    static func load() -> FZSecAPIContext {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KEYCHAIN_SERVICE,
            kSecAttrAccount as String: KEYCHAIN_ACCOUNT_DEFAULT,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return FZSecAPIContext()
        }
        
        guard status == errSecSuccess else {
            logger.error("failed to load FZSecAPIContext from Keychain: \(status)")
            return FZSecAPIContext()
        }
       
        guard let data = item as? Data else {
            logger.error("failed to load FZSecAPIContext from Keychain: status == errSecSuccess but no data")
            
            delete()
            return FZSecAPIContext()
        }
        
        let decoder = JSONDecoder()
        do {
            var context = try decoder.decode(FZSecAPIContext.self, from: data)
            
            guard context.valid() else {
                delete()
                return FZSecAPIContext()
            }
            
            return context
        } catch {
            logger.error("failed to decode FZSecAPIContext from Keychain data: \(error.localizedDescription)")
            
            delete()
            return FZSecAPIContext()
        }
    }
    
    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KEYCHAIN_SERVICE,
            kSecAttrAccount as String: KEYCHAIN_ACCOUNT_DEFAULT
        ]
        
        SecItemDelete(query as CFDictionary)
    }

    
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
            
            
            guard let id = dict["sub"] as? String,
                  let flitzOptions = dict["x-flitz-options"] as? String,
                  flitzOptions == "--with-love"
            else {
                return false
            }
            
            self.payload = dict

            return true
        } catch {
            Self.logger.error("failed to decode JWT payload: \(error.localizedDescription)")
            return false
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.KEYCHAIN_SERVICE,
            kSecAttrAccount as String: Self.KEYCHAIN_ACCOUNT_DEFAULT,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // upsert
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            Self.logger.error("failed to save FZSecAPIContext to Keychain: \(status)")
            return
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
#if DEBUG
        host = try container.decode(FZAPIServerHost.self, forKey: .host)
#endif
        token = try container.decodeIfPresent(String.self, forKey: .token)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
#if DEBUG
        try container.encode(host, forKey: .host)
#endif
        if let token {
            try container.encode(token, forKey: .token)
        }
        
        if let refreshToken {
            try container.encode(refreshToken, forKey: .refreshToken)
        }
    }
}

// for compatibility
typealias FZAPIContext = FZSecAPIContext
