//
//  FZAPIEndpoint.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import Foundation

struct FZAPIEndpoint: RawRepresentable {
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let token = FZAPIEndpoint(rawValue: "/auth/token")
    
    // user start
    static let register = FZAPIEndpoint(rawValue: "/users/register/")
    
    static func user(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/")
    }
    // user end
    
    // card start
    static let cards = FZAPIEndpoint(rawValue: "/cards/")
    static let cardsReceived = FZAPIEndpoint(rawValue: "/cards/received/")

    static func card(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/")
    }
    
    static func setCardAsMain(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/set-as-main/")
    }

    static func cardAssetReferences(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/asset-references/")
    }
    // card end
    
    
    // wave start
    static let waveDiscoveryStart = FZAPIEndpoint(rawValue: "/wave/discovery/start/")
    static let waveDiscoveryEnd = FZAPIEndpoint(rawValue: "/wave/discovery/stop/")
    static let waveReportDiscovery = FZAPIEndpoint(rawValue: "/wave/discovery/report/")
    // wave end
    
    func urlString(for server: String) -> String {
        return "\(server)\(self.rawValue)"
    }
    
    func url(for server: String) -> URL {
        return URL(string: self.urlString(for: server))!
    }
}



fileprivate extension String {
    func sanitizeServerAddress() -> String {
        var server = self
        if server.hasPrefix("https://") {
            server.removeFirst("https://".count)
        } else if server.hasPrefix("http://") {
            server.removeFirst("http://".count)
        } else if server.hasPrefix("wss://") {
            server.removeFirst("wss://".count)
        } else if server.hasPrefix("ws://") {
            server.removeFirst("ws://".count)
        }
        
        if server.hasSuffix("/") {
            server.removeLast()
        }
        
        return server
    }
}
