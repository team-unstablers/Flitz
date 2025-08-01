//
//  FZAPIClient+Messaging.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

import Foundation
import Alamofire

extension FZAPIClient {
    func conversations() async throws -> Paginated<DirectMessageConversation> {
        return try await self.request(to: .conversations, expects: Paginated<DirectMessageConversation>.self)
    }
    
    func createConversation(with participants: [String]) async throws -> DirectMessageConversation {
        let params = CreateConversationRequest(initial_participants: participants)
        return try await self.request(to: .conversations, 
                                      expects: DirectMessageConversation.self, 
                                      method: .post,
                                      parameters: params)
    }
    
    func deleteConversation(id: String) async throws {
        _ = try await self.request(to: .conversation(id: id), 
                                   expects: Ditch.self, 
                                   method: .delete)
    }
    
    func messages(conversationId: String) async throws -> Paginated<DirectMessage> {
        return try await self.request(to: .messages(conversationId: conversationId), 
                                      expects: Paginated<DirectMessage>.self)
    }
    
    func sendMessage(conversationId: String, content: DirectMessageContent) async throws -> DirectMessage {
        let params = SendMessageRequest(content: content)
        return try await self.request(to: .messages(conversationId: conversationId),
                                      expects: DirectMessage.self,
                                      method: .post,
                                      parameters: params)
    }
    
    func deleteMessage(conversationId: String, messageId: String) async throws {
        _ = try await self.request(to: .message(conversationId: conversationId, messageId: messageId),
                                   expects: Ditch.self,
                                   method: .delete)
    }
    
    func markAsRead(conversationId: String) async throws {
        _ = try await self.request(to: .markAsRead(conversationId: conversationId),
                                   expects: MarkAsReadResponse.self,
                                   method: .post)
    }
    
    func uploadAttachment(conversationId: String, file: Data, fileName: String, mimeType: String) async throws -> DirectMessage {
        let url = FZAPIEndpoint.attachments(conversationId: conversationId).url(for: context.host.rawValue)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(context.token!)"
        ]
        
        let response = try await AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "file", fileName: fileName, mimeType: mimeType)
        }, to: url, method: .post, headers: headers)
            .validate()
            .serializingDecodable(DirectMessage.self)
            .response
        
        guard let value = response.value else {
            throw response.error!
        }
        
        return value
    }
}

// Request/Response structs
fileprivate struct CreateConversationRequest: Codable {
    var initial_participants: [String]
}

fileprivate struct SendMessageRequest: Codable {
    var content: DirectMessageContent
}

fileprivate struct MarkAsReadResponse: Codable {
    var status: String
}