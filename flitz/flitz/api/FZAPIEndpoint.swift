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
    static let apnsToken = FZAPIEndpoint(rawValue: "/users/self/apns-token/")
    
    static func user(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/")
    }
    // user end
    
    // card start
    static let cards = FZAPIEndpoint(rawValue: "/cards/")
    static let cardsDistribution = FZAPIEndpoint(rawValue: "/cards/distribution/")

    static func card(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/")
    }
    
    static func setCardAsMain(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/set-as-main/")
    }

    static func cardAssetReferences(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/asset-references/")
    }
    
    static func like(distributionId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/distribution/\(distributionId)/like/")
    }
    
    static func dislike(distributionId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/distribution/\(distributionId)/dislike/")
    }
    // card end
    
    
    // wave start
    static let waveDiscoveryStart = FZAPIEndpoint(rawValue: "/wave/discovery/start/")
    static let waveDiscoveryEnd = FZAPIEndpoint(rawValue: "/wave/discovery/stop/")
    static let waveReportDiscovery = FZAPIEndpoint(rawValue: "/wave/discovery/report/")
    // wave end
    
    // messaging start
    static let conversations = FZAPIEndpoint(rawValue: "/conversations/")
    
    static func conversation(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(id)/")
    }
    
    static func messages(conversationId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(conversationId)/messages/")
    }
    
    static func message(conversationId: String, messageId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(conversationId)/messages/\(messageId)/")
    }
    
    static func markAsRead(conversationId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(conversationId)/messages/mark_as_read/")
    }
    
    static func attachments(conversationId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(conversationId)/attachments/")
    }
    
    static func atttachment(conversationId: String, attachmentId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(conversationId)/attachments/\(attachmentId)/")
    }
    
    // messaging end
    
    func urlString(for server: String) -> String {
        return "\(server)\(self.rawValue)"
    }
    
    func url(for server: String) -> URL {
        return URL(string: self.urlString(for: server))!
    }
}
