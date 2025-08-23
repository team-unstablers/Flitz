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
        }
    }
    
    func loadConversations() async {
        guard let apiClient = apiClient, !isLoading else { return }
        
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
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            .contextMenu {
                                Button("대화에서 나가기") {
                                    viewModel.deleteConversation(id: conversation.id)
                                }
                                
                                Button("대화 신고하기", role: .destructive) {
                                    // TODO: 신고 기능 구현
                                }
                            }
                            .onTapGesture {
                                appState.navState.append(.conversation(conversationId: conversation.id))
                            }
                    }
                    .refreshable {
                        await viewModel.loadConversations()
                    }
                }
            }
            .navigationTitle("메시지")
            .alert("대화 나가기", isPresented: $viewModel.showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("나가기", role: .destructive) {
                    Task {
                        await viewModel.confirmDelete()
                    }
                }
            } message: {
                Text("이 대화에서 나가시겠습니까? 모든 메시지가 삭제됩니다.")
            }
        }
        .onAppear {
            viewModel.configure(with: appState.client)
        }
        .onReceive(appState.conversationUpdated) {
            Task {
                // FIXME
                await viewModel.loadConversations()
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
    ConversationListScreen(viewModel: ConversationListPreviewViewModel())
        .environmentObject(RootAppState())
}

