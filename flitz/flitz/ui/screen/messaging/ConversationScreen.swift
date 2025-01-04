//
//  ConversationScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

class ConversationViewModel: ObservableObject {
    // SORTED BY ID DESC (NEWEST FIRST)
    @Published
    var messages: [DirectMessage] = []
    
    init(conversationId: String) {
        self.messages = [
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385419")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "가장 마지막 메시지입니다"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385418")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385417")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385416")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385414")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385413")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385412")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385411")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            ),
            DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385410")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01 00:00:00"
            )
        ]
    }
    
    func loadPreviousMessages(until id: UUID) {
        // @copilot, 이 부분은 나중에 직접 구현할 것이므로 수정하지 마십시오.
        print("TODO: Implement loadPreviousMessages")
    }
}

struct ConversationScreen: View {
    @StateObject
    var viewModel: ConversationViewModel = ConversationViewModel(conversationId: "1")
   
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages.reversed()) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.sender == "me"
                        )
                        .onAppear {
                            // 위에서 3번째 메시지가 나타나면 이전 메시지 로드
                            if message.id == viewModel.messages[safe: 2]?.id {
                                viewModel.loadPreviousMessages(until: message.id)
                            }
                        }
                    }
                }
            }
            
            MessageComposeArea()
        }
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    ProfileImage(
                        url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg",
                        size: 36
                    )
                    Text("Gyuhwan Park").bold()
                }
            }
        }
    }
}

// Array 안전 접근을 위한 Extension
extension Array {
subscript(safe index: Int) -> Element? {
    return indices.contains(index) ? self[index] : nil
}
}

#Preview {
ConversationScreen()
}
