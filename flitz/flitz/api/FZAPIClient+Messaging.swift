//
//  FZAPIClient+Messaging.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//

import Foundation
import Alamofire
import Combine

extension FZAPIClient {
    /// 대화방별 WebSocket 클라이언트를 관리하는 딕셔너리
    private static var streamClients: [String: FZMessagingStreamClient] = [:]
    private static let streamClientsQueue = DispatchQueue(label: "com.flitz.messaging.streamclients")
    
    /// 특정 대화방의 실시간 메시징 스트림 연결
    func connectMessagingStream(conversationId: String) -> FZMessagingStreamClient {
        Self.streamClientsQueue.sync {
            if let existingClient = Self.streamClients[conversationId] {
                return existingClient
            }
            
            let client = FZMessagingStreamClient(context: context, conversationId: conversationId)
            Self.streamClients[conversationId] = client
            client.connect()
            return client
        }
    }
    
    /// 특정 대화방의 실시간 메시징 스트림 연결 해제
    func disconnectMessagingStream(conversationId: String) {
        Self.streamClientsQueue.sync {
            if let client = Self.streamClients[conversationId] {
                client.disconnect()
                Self.streamClients.removeValue(forKey: conversationId)
            }
        }
    }
    
    /// 모든 실시간 메시징 스트림 연결 해제
    func disconnectAllMessagingStreams() {
        Self.streamClientsQueue.sync {
            Self.streamClients.values.forEach { $0.disconnect() }
            Self.streamClients.removeAll()
        }
    }
    
    func conversations() async throws -> Paginated<DirectMessageConversation> {
        return try await self.request(to: .conversations, expects: Paginated<DirectMessageConversation>.self)
    }
    
    func conversation(id: String) async throws -> DirectMessageConversation {
        return try await self.request(to: .conversation(id: id), expects: DirectMessageConversation.self)
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
    
    func flagConversation(id: String, args: FlagConversationArgs) async throws -> SimpleResponse {
        return try await self.request(to: .flagConversation(id: id),
                                      expects: SimpleResponse.self,
                                      method: .post,
                                      parameters: args)
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
    
    func attachment(conversationId: String, id: String) async throws -> DirectMessageAttachment {
        return try await self.request(to: .atttachment(conversationId: conversationId, attachmentId: id), expects: DirectMessageAttachment.self)
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
