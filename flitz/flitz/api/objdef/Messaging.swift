//
//  Messaging.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/1/25.
//

import Foundation

struct DirectMessageParticipant: Codable {
    var user: FZUser
    var read_at: Int
    
    /// 자기 자신일 때에만 존재함
    var unread_count: Int?
}

/// "UNION TYPE" lol
struct DirectMessageContent: Codable {
    var type: String
    
    // type == "text"의 경우
    var text: String?
    
    // type == "attachment"의 경우
    var attachment_type: String?
    var attachment_id: String?
    
    var public_url: String?
    var thumbnail_url: String?
}

struct DirectMessage: Codable, Identifiable {
    var id: UUID
    var sender: String
    var content: DirectMessageContent
    
    var created_at: String
}


struct DirectMessageConversation: Codable, Identifiable {
    var id: String
    var participants: [DirectMessageParticipant]
    
    var latest_message: DirectMessage?
}

struct DirectMessageAttachment: Codable, Identifiable {
    var id: String
    var type: String
    var public_url: String
    var mimetype: String
    var size: Int
    var created_at: String
    var updated_at: String
}

