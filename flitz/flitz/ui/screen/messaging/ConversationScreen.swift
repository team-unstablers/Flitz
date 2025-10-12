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
    private let logger = createFZOSLogger("ConversationViewModel")
    
    @Published var messages: [DirectMessage] = []
    @Published var conversation: DirectMessageConversation?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isSending = false
    @Published var isReconnecting = false
    @Published var connectionState: ConnectionState = .disconnected
    
    @Published var isComposeAreaFocused: Bool = false
    
    private var currentPage: Paginated<DirectMessage>?
    private var apiClient: FZAPIClient?
    private var currentUserId: String?
    private var streamClient: FZMessagingStreamClient?
    private var cancellables = Set<AnyCancellable>()
    let conversationId: String
    
    // 재연결 관련 변수
    private var reconnectAttempts = 0
    private var reconnectTask: Task<Void, Never>?
    private var lastMessageDate: Date?
    
    @Published var readState: [String: Date] = [:]
    @Published var opponentId: String? = nil
    
    enum ConnectionState: Equatable {
        case connected
        case disconnected
        case reconnecting(attempt: Int)
        
        static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
            switch (lhs, rhs) {
            case (.connected, .connected):
                return true
            case (.disconnected, .disconnected):
                return true
            case (.reconnecting(let a), .reconnecting(let b)):
                return a == b
            default:
                return false
            }
        }
    }
    
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
    
    func connectWebSocket() {
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
    
    private func reconnectWebSocket() async {
        reconnectAttempts += 1
        connectionState = .reconnecting(attempt: reconnectAttempts)
        isReconnecting = true
        
        // 지수 백오프: max(5, 2^n) 초 (최대 32초)
        logger.info("[WebSocket] Reconnecting in 2 seconds (attempt \(reconnectAttempts))")
        
        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
        
        // 재연결 시도
        connectWebSocket()
    }
    
    func disconnectWebSocket() {
        reconnectTask?.cancel()
        reconnectTask = nil
        
        if let apiClient = apiClient {
            apiClient.disconnectMessagingStream(conversationId: conversationId)
        }
        streamClient = nil
        cancellables.removeAll()
        connectionState = .disconnected
        isReconnecting = false
    }
    
    private func handleStreamEvent(_ event: FZMessagingStreamClient.StreamEvent) {
        switch event {
        case .connected:
            logger.info("[WebSocket] Connected to conversation: \(conversationId)")
            connectionState = .connected
            isReconnecting = false
            reconnectAttempts = 0
            
            // 재연결 성공 시 놓친 메시지 가져오기
            if let lastDate = lastMessageDate {
                Task {
                    await fetchMissedMessages(since: lastDate)
                }
            }
            
        case .disconnected(let error):
            logger.warning("[WebSocket] Disconnected: \(error?.localizedDescription ?? "Unknown")")
            connectionState = .disconnected
            
            // 자동 재연결 시작
            reconnectTask?.cancel()
            reconnectTask = Task {
                await reconnectWebSocket()
            }
            
        case .message(let message):
            // 중복 메시지 체크 후 추가
            if !messages.contains(where: { $0.id == message.id }) {
                messages.append(message)
                // 마지막 메시지 날짜 업데이트
                lastMessageDate = message.created_at.asISO8601Date
            }
            
            Task {
                await self.markAsRead()
            }
            
        case .readEvent(let userId, let readAt):
            // 읽음 상태 업데이트
            logger.debug("[WebSocket] User \(userId) read messages at \(readAt)")
            // 대화 참여자의 읽음 시간 업데이트
            self.readState[userId] = readAt
            
        case .error(let error):
            logger.error("[WebSocket] Error: \(error)")
            // 에러 발생 시에도 재연결 시도
            if connectionState == .connected {
                connectionState = .disconnected
                reconnectTask?.cancel()
                reconnectTask = Task {
                    await reconnectWebSocket()
                }
            }
        }
    }
    
    private func fetchMissedMessages(since date: Date) async {
        guard let apiClient = apiClient else { return }
        
        logger.debug("[WebSocket] Fetching missed messages since \(date)")
        
        do {
            // 최신 메시지들을 가져옴
            let page = try await apiClient.messages(conversationId: conversationId)
            let newMessages = page.results.filter { message in
                guard let messageDate = message.created_at.asISO8601Date else { return false }
                return messageDate > date
            }
            
            // 중복 제거하고 추가
            for message in newMessages.reversed() {
                if !messages.contains(where: { $0.id == message.id }) {
                    messages.append(message)
                }
            }
            
            // 이미지 프리페칭
            if !newMessages.isEmpty {
                prefetchImages(from: newMessages)
            }
        } catch {
            logger.error("[WebSocket] Failed to fetch missed messages: \(error)")
        }
    }
    
    func loadConversation() async {
        guard let apiClient = apiClient else { return }
        
        do {
            let conversation = try await apiClient.conversation(id: conversationId)
            self.conversation = conversation
            
            self.opponentId = self.conversation?.participants.first(where: { $0.user.id != currentUserId })?.user.id
            self.readState = [:]
            
            for participant in self.conversation?.participants ?? [] {
                if let readAt = participant.read_at?.asISO8601Date {
                    self.readState[participant.user.id] = readAt
                }
            }
        } catch {
            logger.error("[Conversation] Failed to load conversation info: \(error)")
        }
    }
    
    func loadMessages() async {
        guard let apiClient = apiClient, !isLoading else { return }
        
        isLoading = true
        do {
            let page = try await apiClient.messages(conversationId: conversationId)
            self.currentPage = page
            self.messages = page.results.reversed() // API는 최신순, UI는 오래된순
            
            // 마지막 메시지 날짜 저장
            if let lastMessage = page.results.first {
                lastMessageDate = lastMessage.created_at.asISO8601Date
            }
            
            // 이미지 프리페칭
            prefetchImages(from: page.results)
        } catch {
            logger.error("[Conversation] Failed to load messages: \(error)")
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
            logger.error("[Conversation] Failed to load more messages: \(error)")
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
            logger.error("[Conversation] Failed to send message: \(error)")
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
            logger.error("[Conversation] Failed to send image: \(error)")
        }
        isSending = false
    }
    
    func deleteMessage(id: String) async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.deleteMessage(conversationId: conversationId, messageId: id)
            messages.removeAll { $0.id.uuidString == id }
        } catch {
            logger.error("[Conversation] Failed to delete message: \(error)")
        }
    }
    
    func markAsRead() async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.markAsRead(conversationId: conversationId)
            // WebSocket을 통해서도 읽음 확인 전송
            // streamClient?.sendReadReceipt()
        } catch {
            logger.error("[Conversation] Failed to mark as read: \(error)")
        }
    }
    
    func isFromCurrentUser(_ message: DirectMessage) -> Bool {
        return message.sender == currentUserId
    }
    
    private func prefetchImages(from messages: [DirectMessage]) {
        Task {
            await withTaskGroup { group in
                for message in messages.filter({ $0.content.type == "attachment" }) {
                    guard let attachmentId = message.content.attachment_id,
                          let thumbnailUrl = message.content.thumbnail_url,
                          let url = URL(string: thumbnailUrl)
                    else {
                        continue
                    }
                    
                    let identifier = "message:attachment:\(attachmentId)"
                    
                    group.addTask {
                        await ImageCacheStorage.shared.resolve(by: identifier, origin: url)
                    }
                }
            }
        }
    }
    
    func removeThreadNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getDeliveredNotifications { delivered in
            let ids = delivered
                .filter { $0.request.content.threadIdentifier == self.conversationId }
                .map { $0.request.identifier }
            
            center.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}

struct ConversationScreen: View {
    private let logger = createFZOSLogger("ConversationScreen")
    
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.scenePhase)
    var scenePhase
    
    @Environment(\.userId)
    var userId

    @StateObject
    var viewModel: ConversationViewModel

    init(conversationId: String) {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(conversationId: conversationId))
    }
   
    var body: some View {
        FZConversationView(conversationId: viewModel.conversationId, viewModel: viewModel)
            .ignoresSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let conversation = viewModel.conversation,
                       let opponent = conversation.participants.first(where: { $0.user.id != userId }) {
                        HStack {
                            ProfileImage(
                                url: opponent.user.profile_image_url,
                                userId: opponent.user.id,
                                size: 36
                            )
                            Text(opponent.user.display_name).bold()
                        }
                        .onTapGesture {
                            viewModel.isComposeAreaFocused = false
                            appState.currentModal = .userProfile(userId: opponent.user.id)
                        }
                    } else {
                        Text(NSLocalizedString("ui.messaging.conversation.title", comment: "대화"))
                    }
                }
            }
            .environment(\.conversationId, viewModel.conversationId)
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
            user: .mock0,
            read_at: nil
        )
        let userOther = DirectMessageParticipant(
            user: .mock1,
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
