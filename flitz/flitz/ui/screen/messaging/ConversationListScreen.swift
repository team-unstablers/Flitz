//
//  ConversationListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

class ConversationListViewModel: ObservableObject {
    @Published
    var conversations: [DirectMessageConversation] = []
    
    
}

struct ConversationListScreen: View {
    @EnvironmentObject
    var appState: RootAppState

#if DEBUG
    @StateObject
    var viewModel = ConversationListPreviewViewModel()
#else
    @StateObject
    var viewModel = ConversationListViewModel()
#endif
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.conversations) { conversation in
                    ConversationListItem(conversation: conversation)
                        .contextMenu {
                            Button("대화에서 나가기") {
                                
                            }
                            
                            Button("대화 신고하기", role: .destructive) {
                            }
                            
                        }
                        .onTapGesture {
                            appState.navState.append(.conversation(conversationId: conversation.id))
                        }
                }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
                .listStyle(.plain)
                .navigationTitle("메시지")
        }
    }
}

#if DEBUG
class ConversationListPreviewViewModel: ConversationListViewModel {
    override init() {
        super.init()
        
        let userSelf = DirectMessageParticipant(user: FZUser(id: "self",
                                                             username: "self",
                                                             display_name: "Flitz User"),
                                                read_at: "2020-04-01T00:00:00Z",
                                                unread_count: 3)
        
        let userOther = DirectMessageParticipant(user: FZUser(id: "other",
                                                              username: "other",
                                                              display_name: "Other User",
                                                              profile_image_url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg"),
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
    }
}
#endif

#Preview {
    ConversationListScreen(viewModel: ConversationListPreviewViewModel())
        .environmentObject(RootAppState())
}

