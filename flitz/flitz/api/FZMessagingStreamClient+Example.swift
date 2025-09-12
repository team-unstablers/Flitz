//
//  FZMessagingStreamClient+Example.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/1/25.
//
//  이 파일은 FZMessagingStreamClient 사용 예제입니다.
//

import Foundation
import Combine

/*
 사용 예제:
 
 class ChatViewModel: ObservableObject {
     private let apiClient: FZAPIClient
     private var streamClient: FZMessagingStreamClient?
     private var cancellables = Set<AnyCancellable>()
     
     @Published var messages: [DirectMessage] = []
     @Published var connectionState: FZMessagingStreamClient.ConnectionState = .disconnected
     
     init(apiClient: FZAPIClient) {
         self.apiClient = apiClient
     }
     
     func connectToConversation(_ conversationId: String) {
         // 기존 메시지 로드
         Task {
             do {
                 let paginatedMessages = try await apiClient.messages(conversationId: conversationId)
                 await MainActor.run {
                     self.messages = paginatedMessages.results
                 }
             } catch {
                 print("Failed to load messages: \(error)")
             }
         }
         
         // WebSocket 연결
         streamClient = apiClient.connectMessagingStream(conversationId: conversationId)
         
         // 연결 상태 구독
         streamClient?.connectionStatePublisher
             .receive(on: DispatchQueue.main)
             .sink { [weak self] state in
                 self?.connectionState = state
             }
             .store(in: &cancellables)
         
         // 이벤트 구독
         streamClient?.eventPublisher
             .receive(on: DispatchQueue.main)
             .sink { [weak self] event in
                 self?.handleStreamEvent(event)
             }
             .store(in: &cancellables)
     }
     
     func disconnect() {
         if let conversationId = messages.first?.id.uuidString {
             apiClient.disconnectMessagingStream(conversationId: conversationId)
         }
         streamClient = nil
     }
     
     private func handleStreamEvent(_ event: FZMessagingStreamClient.StreamEvent) {
         switch event {
         case .connected:
             print("WebSocket connected")
             
         case .disconnected(let error):
             print("WebSocket disconnected: \(error?.localizedDescription ?? "Unknown")")
             
         case .message(let message):
             // 새 메시지 추가
             if !messages.contains(where: { $0.id == message.id }) {
                 messages.append(message)
             }
             
         case .readEvent(let userId, let readAt):
             // 읽음 상태 업데이트
             print("User \(userId) read messages at \(readAt)")
             // UI 업데이트 로직
             
         case .error(let error):
             print("WebSocket error: \(error)")
         }
     }
     
     func sendMessage(_ text: String) {
         let content = DirectMessageContent(
             type: "text",
             text: text,
             attachment_type: nil,
             attachment_id: nil,
             public_url: nil,
             thumbnail_url: nil
         )
         
         Task {
             do {
                 let message = try await apiClient.sendMessage(
                     conversationId: messages.first?.id.uuidString ?? "",
                     content: content
                 )
                 // 메시지가 WebSocket을 통해 자동으로 수신됨
             } catch {
                 print("Failed to send message: \(error)")
             }
         }
     }
     
     func markAsRead() {
         // 수동으로 읽음 확인 전송
         streamClient?.sendReadReceipt()
     }
 }
 
 // SwiftUI View 예제
 struct ChatView: View {
     @StateObject private var viewModel: ChatViewModel
     @State private var messageText = ""
     
     init(apiClient: FZAPIClient, conversationId: String) {
         _viewModel = StateObject(wrappedValue: ChatViewModel(apiClient: apiClient))
     }
     
     var body: some View {
         VStack {
             // 연결 상태 표시
             ConnectionStatusView(state: viewModel.connectionState)
             
             // 메시지 목록
             ScrollView {
                 LazyVStack {
                     ForEach(viewModel.messages) { message in
                         MessageView(message: message)
                     }
                 }
             }
             
             // 메시지 입력
             HStack {
                 TextField(NSLocalizedString("ui.messaging.textfield.message_example.placeholder", comment: "메시지 입력..."), text: $messageText)
                 Button(NSLocalizedString("ui.messaging.action.send", comment: "전송")) {
                     viewModel.sendMessage(messageText)
                     messageText = ""
                 }
             }
             .padding()
         }
         .onAppear {
             viewModel.connectToConversation("conversation-id-here")
         }
         .onDisappear {
             viewModel.disconnect()
         }
     }
 }
 */