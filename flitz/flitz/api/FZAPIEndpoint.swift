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
    static let refreshToken = FZAPIEndpoint(rawValue: "/auth/token/refresh")
    
    // MARK: registration
    static let startRegistration = FZAPIEndpoint(rawValue: "/users/register/start/")
    static let completeRegistration = FZAPIEndpoint(rawValue: "/users/register/complete/")
    
    static let registrationUsernameAvailability = FZAPIEndpoint(rawValue: "/users/register/username-availability/")
    
    static let registrationStartPhoneVerification = FZAPIEndpoint(rawValue: "/users/register/phone-verification/start/")
    static let registrationCompletePhoneVerification = FZAPIEndpoint(rawValue: "/users/register/phone-verification/complete/")

    // MARK: user
    static let apnsToken = FZAPIEndpoint(rawValue: "/users/self/apns-token/")
    
    static func user(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/")
    }
    
    static func userBlock(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/block/")
    }
    
    
    static func flagUser(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/users/\(id)/flag/")
    }

    static let selfProfileImage = FZAPIEndpoint(rawValue: "/users/self/profile-image/")
    static let selfSettings = FZAPIEndpoint(rawValue: "/users/self/settings/")
    static let selfPasswd = FZAPIEndpoint(rawValue: "/users/self/passwd/")
    static let selfIdentity = FZAPIEndpoint(rawValue: "/users/self/identity/")
    static let selfWaveSafetyZone = FZAPIEndpoint(rawValue: "/users/self/wave-safety-zone/")
    static let selfDeactivate = FZAPIEndpoint(rawValue: "/users/self/deactivate/")
    
    // MARK: card
    static let cards = FZAPIEndpoint(rawValue: "/cards/")
    static let cardsDistribution = FZAPIEndpoint(rawValue: "/cards/distribution/")
    static let cardFavorites = FZAPIEndpoint(rawValue: "/cards/favorites/")

    static func card(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/")
    }
    
    static func flagCard(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/\(id)/flag/")
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
    
    static func cardFavorite(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/cards/favorites/\(id)/")
    }
    
    // MARK: wave
    static let waveDiscoveryStart = FZAPIEndpoint(rawValue: "/wave/discovery/start/")
    static let waveDiscoveryEnd = FZAPIEndpoint(rawValue: "/wave/discovery/stop/")
    static let waveReportDiscovery = FZAPIEndpoint(rawValue: "/wave/discovery/report/")
    static let waveUpdateLocation = FZAPIEndpoint(rawValue: "/wave/discovery/update/")
    
    
    // MARK: messaging
    static let conversations = FZAPIEndpoint(rawValue: "/conversations/")
    static let conversationsTotalUnreadCount = FZAPIEndpoint(rawValue: "/conversations/total_unread_count/")

    static func conversation(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(id)/")
    }
    
    static func flagConversation(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/conversations/\(id)/flag/")
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
    
    
    // MARK: safety
    static let blocks = FZAPIEndpoint(rawValue: "/blocks/")
    
    static let contactTriggers = FZAPIEndpoint(rawValue: "/contact-triggers/")
    
    static func contactTrigger(triggerId: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/contact-triggers/\(triggerId)/")
    }
    
    static let contactTriggersEnabled = FZAPIEndpoint(rawValue: "/contact-triggers/enabled/")
    static let contactTriggersBulkCreate = FZAPIEndpoint(rawValue: "/contact-triggers/bulk-create/")
    static let contactTriggersAll = FZAPIEndpoint(rawValue: "/contact-triggers/all/")
    
    // MARK: notice
    static let notices = FZAPIEndpoint(rawValue: "/notices/")
    static func notice(id: String) -> FZAPIEndpoint {
        return FZAPIEndpoint(rawValue: "/notices/\(id)/")
    }

    // MARK: utility functions
    func urlString(for server: String) -> String {
        return "\(server)\(self.rawValue)"
    }
    
    func url(for server: String) -> URL {
        return URL(string: self.urlString(for: server))!
    }
}
