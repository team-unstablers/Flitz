//
//  ConversationScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
class ConversationViewModel: ObservableObject {
    @Published var messages: [DirectMessage] = []
    @Published var conversation: DirectMessageConversation?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isSending = false
    
    private var currentPage: Paginated<DirectMessage>?
    private var apiClient: FZAPIClient?
    private var currentUserId: String?
    private var streamClient: FZMessagingStreamClient?
    private var cancellables = Set<AnyCancellable>()
    let conversationId: String
    
    @Published var readState: [String: Date] = [:]
    @Published var opponentId: String? = nil
    
    init(conversationId: String) {
        self.conversationId = conversationId
    }
    
    func configure(with apiClient: FZAPIClient, currentUserId: String) {
        self.apiClient = apiClient
        self.currentUserId = currentUserId
        
        // WebSocket 연결 설정
        connectWebSocket()
        
        Task {
            await loadConversation()
            await loadMessages()
            await markAsRead()
        }
    }
    
    private func connectWebSocket() {
        guard let apiClient = apiClient else { return }
        
        // WebSocket 연결
        streamClient = apiClient.connectMessagingStream(conversationId: conversationId)
        
        // 이벤트 구독
        streamClient?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleStreamEvent(event)
            }
            .store(in: &cancellables)
    }
    
    func disconnectWebSocket() {
        if let apiClient = apiClient {
            apiClient.disconnectMessagingStream(conversationId: conversationId)
        }
        streamClient = nil
        cancellables.removeAll()
    }
    
    private func handleStreamEvent(_ event: FZMessagingStreamClient.StreamEvent) {
        switch event {
        case .connected:
            print("[WebSocket] Connected to conversation: \(conversationId)")
            
        case .disconnected(let error):
            print("[WebSocket] Disconnected: \(error?.localizedDescription ?? "Unknown")")
            
        case .message(let message):
            // 중복 메시지 체크 후 추가
            if !messages.contains(where: { $0.id == message.id }) {
                messages.append(message)
            }
            
            Task {
                await self.markAsRead()
            }
            
        case .readEvent(let userId, let readAt):
            // 읽음 상태 업데이트
            print("[WebSocket] User \(userId) read messages at \(readAt)")
            // 대화 참여자의 읽음 시간 업데이트
            self.readState[userId] = readAt
            
        case .error(let error):
            print("[WebSocket] Error: \(error)")
        }
    }
    
    func loadConversation() async {
        guard let apiClient = apiClient else { return }
        
        do {
            // TODO: 단일 conversation을 가져오는 API 엔드포인트가 필요함
            // 현재는 전체 리스트를 가져와서 필터링하는 비효율적인 방식
            let conversations = try await apiClient.conversations()
            self.conversation = conversations.results.first { $0.id == conversationId }
            
            self.opponentId = self.conversation?.participants.first(where: { $0.user.id != currentUserId })?.user.id
            self.readState = [:]
            
            for participant in self.conversation?.participants ?? [] {
                if let readAt = participant.read_at?.asISO8601Date {
                    self.readState[participant.user.id] = readAt
                }
            }
        } catch {
            print("[Conversation] Failed to load conversation info: \(error)")
        }
    }
    
    func loadMessages() async {
        guard let apiClient = apiClient, !isLoading else { return }
        
        isLoading = true
        do {
            let page = try await apiClient.messages(conversationId: conversationId)
            self.currentPage = page
            self.messages = page.results.reversed() // API는 최신순, UI는 오래된순
            
            // 이미지 프리페칭
            prefetchImages(from: page.results)
        } catch {
            print("[Conversation] Failed to load messages: \(error)")
        }
        isLoading = false
    }
    
    func loadPreviousMessages() async {
        guard let apiClient = apiClient,
              let currentPage = currentPage,
              let nextUrl = currentPage.next,
              !isLoadingMore else { return }
        
        isLoadingMore = true
        do {
            guard let page = try await apiClient.nextPage(currentPage) else {
                return
            }
            self.currentPage = page
            self.messages.insert(contentsOf: page.results.reversed(), at: 0)
            
            // 이미지 프리페칭
            prefetchImages(from: page.results)
        } catch {
            print("[Conversation] Failed to load more messages: \(error)")
        }
        isLoadingMore = false
    }
    
    func sendMessage(request: MessageRequest) async {
        let isEmpty = request.text.isEmpty && request.images.isEmpty
        
        guard let apiClient = apiClient, !isEmpty, !isSending else { return }
        
        isSending = true
        
        do {
            for image in request.images {
                guard let jpg = image.jpegData(compressionQuality: 0.9) else {
                    continue
                }
                
                _ = try await apiClient.uploadAttachment(conversationId: conversationId,
                                                         file: jpg,
                                                         fileName: "image.jpg",
                                                         mimeType: "image/jpeg")
            }
            
            guard !request.text.isEmpty else {
                isSending = false
                return
            }
            
            let content = DirectMessageContent(type: "text", text: request.text)
            let message = try await apiClient.sendMessage(conversationId: conversationId, content: content)
            // WebSocket을 통해 메시지가 자동으로 수신되므로 여기서는 추가하지 않음
            // 만약 WebSocket이 연결되지 않았다면 수동으로 추가
            if streamClient == nil {
                messages.append(message)
            }
        } catch {
            print("[Conversation] Failed to send message: \(error)")
        }
        isSending = false
    }
    
    func sendImage(data: Data, fileName: String, mimeType: String) async {
        guard let apiClient = apiClient, !isSending else { return }
        
        isSending = true
        do {
            let message = try await apiClient.uploadAttachment(conversationId: conversationId, file: data, fileName: fileName, mimeType: mimeType)
            // WebSocket을 통해 메시지가 자동으로 수신되므로 여기서는 추가하지 않음
            // 만약 WebSocket이 연결되지 않았다면 수동으로 추가
            if streamClient == nil {
                messages.append(message)
            }
        } catch {
            print("[Conversation] Failed to send image: \(error)")
        }
        isSending = false
    }
    
    func deleteMessage(id: String) async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.deleteMessage(conversationId: conversationId, messageId: id)
            messages.removeAll { $0.id.uuidString == id }
        } catch {
            print("[Conversation] Failed to delete message: \(error)")
        }
    }
    
    func markAsRead() async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.markAsRead(conversationId: conversationId)
            // WebSocket을 통해서도 읽음 확인 전송
            // streamClient?.sendReadReceipt()
        } catch {
            print("[Conversation] Failed to mark as read: \(error)")
        }
    }
    
    func isFromCurrentUser(_ message: DirectMessage) -> Bool {
        return message.sender == currentUserId
    }
    
    private func prefetchImages(from messages: [DirectMessage]) {
        let imageUrls = messages.compactMap { message -> URL? in
            guard message.content.type == "attachment" else { return nil }
            if let thumbnailUrl = message.content.thumbnail_url {
                return URL(string: thumbnailUrl)
            } else if let publicUrl = message.content.public_url {
                return URL(string: publicUrl)
            }
            return nil
        }
        
        if !imageUrls.isEmpty {
            ImageCacheManager.shared.prefetchImages(urls: imageUrls)
        }
    }
}

struct ConversationScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel: ConversationViewModel
    
    @State
    private var selectedItem: PhotosPickerItem?
    
    @State
    private var shouldStickToBottom = true
    
    @FocusState
    private var composeAreaFocused: Bool

    init(conversationId: String) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(conversationId: conversationId))
    }
   
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    List {
                        // 로딩 인디케이터
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: viewModel.isFromCurrentUser(message),
                                isRead: viewModel.opponentId != nil && viewModel.readState[viewModel.opponentId!] != nil 
                                    ? viewModel.readState[viewModel.opponentId!]! >= message.created_at.asISO8601Date!
                                    : false
                            )
                            .drawingGroup()
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowBackground(Color.clear)
                            .contextMenu {
                                if viewModel.isFromCurrentUser(message) {
                                    Button("메시지 삭제", role: .destructive) {
                                        Task {
                                            await viewModel.deleteMessage(id: message.id.uuidString)
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                // 위에서 3번째 메시지가 나타나면 이전 메시지 로드
                                if message.id == viewModel.messages[safe: 2]?.id {
                                    Task {
                                        await viewModel.loadPreviousMessages()
                                    }
                                }
                                
                                // 마지막 메시지가 나타나면 스크롤 상태 업데이트
                                if message.id == viewModel.messages.last?.id {
                                    shouldStickToBottom = true
                                }
                            }
                        }
                        
                        // 하단 패딩용 빈 뷰
                        Color.clear
                            .frame(height: 1)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .id("bottomAnchor")
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .defaultScrollAnchor(.bottom)
                    .onChange(of: viewModel.messages.count) { oldCount, newCount in
                        // 새 메시지가 추가되었을 때만 스크롤
                        if newCount > oldCount && shouldStickToBottom {
                            proxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                    .onChange(of: composeAreaFocused) { _, newValue in
                        if newValue && shouldStickToBottom {
                            // 키보드가 나타날 때 스크롤
                            proxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            MessageComposeArea(
                focused: $composeAreaFocused,
                onSend: { request in
                    Task {
                        await viewModel.sendMessage(request: request)
                    }
                    
                    DispatchQueue.main.async {
                        composeAreaFocused = true
                    }
                },
                isSending: viewModel.isSending
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let conversation = viewModel.conversation,
                   let opponent = conversation.participants.first(where: { $0.user.id != appState.profile?.id }) {
                    HStack {
                        ProfileImage(
                            url: opponent.user.profile_image_url,
                            size: 36
                        )
                        Text(opponent.user.display_name).bold()
                    }
                } else {
                    Text("대화")
                }
            }
        }
        .onAppear {
            viewModel.configure(with: appState.client, currentUserId: appState.profile?.id ?? "self")
        }
        .onDisappear {
            viewModel.disconnectWebSocket()
        }
    }
}

// Array 안전 접근을 위한 Extension
fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#if DEBUG
class ConversationPreviewViewModel: ConversationViewModel {
    override init(conversationId: String) {
        super.init(conversationId: conversationId)
        
        self.messages = [
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385410")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 처음 메시지입니다."
                ),
                created_at: "2025-01-01T10:00:00Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385411")!,
                sender: "self",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "2025-01-01T10:01:00Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385412")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "네 반가워요! 오늘 날씨가 좋네요"
                ),
                created_at: "2025-01-01T10:02:00Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385413")!,
                sender: "self",
                content: DirectMessageContent(
                    type: "attachment",
                    attachment_type: "image",
                    thumbnail_url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg"
                ),
                created_at: "2025-01-01T10:03:00Z"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385419")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "멋진 사진이네요!"
                ),
                created_at: "2025-01-01T10:04:00Z"
            )
        ]
        
        // Preview용 대화 정보
        let userSelf = DirectMessageParticipant(
            user: FZUser(id: "self", username: "self", display_name: "나"),
            read_at: nil
        )
        let userOther = DirectMessageParticipant(
            user: FZUser(
                id: "other",
                username: "other",
                display_name: "Gyuhwan Park",
                profile_image_url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg"
            ),
            read_at: nil
        )
        
        self.conversation = DirectMessageConversation(
            id: conversationId,
            participants: [userSelf, userOther],
            latest_message: messages.last
        )
    }
    
    override func sendMessage(request: MessageRequest) async {
        let newMessage = DirectMessage(
            id: UUID(),
            sender: "self",
            content: DirectMessageContent(type: "text", text: request.text),
            created_at: ISO8601DateFormatter().string(from: Date())
        )
        messages.append(newMessage)
    }
}
#endif

#Preview {
    NavigationView {
        ConversationScreen(conversationId: "preview-conversation")
            .environmentObject(RootAppState())
    }
}
