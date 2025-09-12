//
//  ConversationListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

// TODO: SQLite를 도입해야 한다...!
@MainActor
class ConversationListViewModel: ObservableObject {
    @Published var conversations: [DirectMessageConversation] = []
    @Published var initialBusy = true
    @Published var isLoading = false
    @Published var hasMoreData = true
    @Published var showDeleteAlert = false
    
    private var currentPage: Paginated<DirectMessageConversation>?
    private var deleteTargetId: String?
    private var apiClient: FZAPIClient?
    
    func configure(with apiClient: FZAPIClient) {
        self.apiClient = apiClient
        Task {
            await loadConversations()
            RootAppState.shared.conversationBadgeUpdated.send()
        }
    }
    
    func loadConversations() async {
        guard let apiClient = apiClient, !isLoading else { return }
        defer {
            initialBusy = false
        }
        
        isLoading = true
        do {
            let page = try await apiClient.conversations()
            self.currentPage = page
            self.conversations = page.results
            self.hasMoreData = page.next != nil
        } catch {
            print("[ConversationList] Failed to load conversations: \(error)")
        }
        isLoading = false
    }
    
    func loadMore() async {
        guard let apiClient = apiClient,
              let currentPage = currentPage,
              let nextUrl = currentPage.next else { return }
        
        do {
            guard let page = try await apiClient.nextPage(currentPage) else {
                return
            }
            self.currentPage = page
            self.conversations.append(contentsOf: page.results)
            self.hasMoreData = page.next != nil
        } catch {
            print("[ConversationList] Failed to load more conversations: \(error)")
        }
    }
    
    func deleteConversation(id: String) {
        deleteTargetId = id
        showDeleteAlert = true
    }
    
    func confirmDelete() async {
        guard let apiClient = apiClient, let targetId = deleteTargetId else { return }
        
        do {
            try await apiClient.deleteConversation(id: targetId)
            conversations.removeAll { $0.id == targetId }
        } catch {
            print("[ConversationList] Failed to delete conversation: \(error)")
        }
        deleteTargetId = nil
    }
}

struct ConversationListScreen: View {
    @EnvironmentObject var appState: RootAppState
    @StateObject var viewModel = ConversationListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.initialBusy || (viewModel.isLoading && viewModel.conversations.isEmpty) {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if viewModel.conversations.isEmpty {
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("ui.messaging.list.empty.title", comment: "아직 대화 내역이 없어요"))
                                .font(.heading2)
                                .bold()
                                .foregroundStyle(Color.Grayscale.gray8)
                            
                            Text(NSLocalizedString("ui.messaging.list.empty.message", comment: "서로가 카드를 **좋아요** 하면 대화를 시작할 수 있어요."))
                                .multilineTextAlignment(.center)
                                .font(.main)
                                .foregroundStyle(Color.Grayscale.gray7)
                        }
                    } else {
                        FZInfiniteScrollView(
                            data: viewModel.conversations,
                            hasMoreData: $viewModel.hasMoreData,
                            loadingView: {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            },
                            onLoadMore: {
                                await viewModel.loadMore()
                            }
                        ) { conversation in
                            ConversationListItem(conversation: conversation)
                                .onTapGesture {
                                    appState.navState.append(.conversation(conversationId: conversation.id))
                                }
                        }
                        .refreshable {
                            await viewModel.loadConversations()
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("ui.messaging.list.page_title", comment: "메시지"))
            .alert("ui.messaging.list.leave_alert.title", isPresented: $viewModel.showDeleteAlert) {
                Button(NSLocalizedString("ui.common.cancel", comment: "취소"), role: .cancel) { }
                Button(NSLocalizedString("ui.messaging.list.leave", comment: "나가기"), role: .destructive) {
                    Task {
                        await viewModel.confirmDelete()
                    }
                }
            } message: {
                Text(NSLocalizedString("ui.messaging.list.leave_alert.message", comment: "이 대화에서 나가시겠습니까? 모든 메시지가 삭제됩니다."))
            }
        }
        .onAppear {
            viewModel.configure(with: appState.client)
        }
        .onReceive(appState.conversationUpdated) {
            // 대화 목록 갱신은 네비게이션 스택이 비어 있을 때만 수행
            guard appState.navState.isEmpty else {
                return
            }
            
            Task {
                // FIXME
                await viewModel.loadConversations()
                appState.conversationBadgeUpdated.send()
            }
        }
    }
}

#if DEBUG
class ConversationListPreviewViewModel: ConversationListViewModel {
    override init() {
        super.init()
        
        let userSelf = DirectMessageParticipant(user: .mock1,
                                                read_at: "2020-04-01T00:00:00Z",
                                                unread_count: 3)
        
        let userOther = DirectMessageParticipant(user: .mock0,
                                                 read_at: "2020-04-01T00:00:00Z")
        
        
        let latest_message_1 = DirectMessage(id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385417")!,
                                             sender: "other",
                                             content: DirectMessageContent(type: "text",
                                                                           text: "메로스는 격노했다. 기필코 저 포악하기 짝이 없는 왕을 없애겠다고 결의했다. 메로스는 정치를 알지 못한다. 메로스는 마을의 양치기에 지나지 않으니까. 피리를 불며 양과 놀며 지내왔다. 그럼에도 사악한 것에는 다른 사람보다 더욱 민감하였다."),
                                             created_at: "1970-01-01T00:00:00Z")
        
        let latest_message_2 = DirectMessage(id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385418")!,
                                             sender: "other",
                                             content: DirectMessageContent(type: "attachment",
                                                                           attachment_type: "image"),
                                             created_at: "2025-01-01T21:45:00Z")
        
        let conversation1 = DirectMessageConversation(id: "test1",
                                                      participants: [
                                                        userSelf,
                                                        userOther
                                                      ],
                                                      latest_message: latest_message_1)
        
        let conversation2 = DirectMessageConversation(id: "test2",
                                                        participants: [
                                                            userSelf,
                                                            userOther
                                                        ],
                                                        latest_message: latest_message_2)
        

        conversations = [conversation1, conversation2]
        hasMoreData = false  // 프리뷰에서는 더 이상 데이터 없음
    }
}
#endif

#Preview {
#if DEBUG
    ConversationListScreen(viewModel: ConversationListPreviewViewModel())
        .environmentObject(RootAppState())
#endif
}

