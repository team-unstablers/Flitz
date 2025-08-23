//
//  MessageListIem.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/1/25.
//

import SwiftUI

struct MessageListItemBadge: View {
    var count: Int
    
    var body: some View {
        if count == 0 {
            EmptyView()
                .frame(width: 24, height: 24)
                .padding(.vertical, 4)
        } else {
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(.red)
                .clipShape(Circle())
                .padding(.vertical, 4)
        }
    }
}

struct ConversationListItem: View {
    @Environment(\.userId)
    var userId: String
    
    var conversation: DirectMessageConversation
    
    var opponent: DirectMessageParticipant? {
        conversation.participants.first { $0.user.id != userId }
    }
    
    @State
    var isFlagSheetVisible = false
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                if let opponent = opponent {
                    ProfileImage(url: opponent.user.profile_image_url, userId: opponent.user.id)
                        .padding(.trailing, 4)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(opponent?.user.display_name ?? "알 수 없음")
                        .font(.heading3)
                        .bold()
                        .lineLimit(1)
                    Text(conversation.displayText)
                        .font(.main)
                        .lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(conversation.displayRelativeTime)
                    .font(.main)
                    .lineLimit(1)
                
                MessageListItemBadge(count: conversation.unreadCount(for: userId))
            }
        }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .overlay(Divider(), alignment: .bottom)
            .contextMenu {
                Button("사용자 차단하기", role: .destructive) {
                    
                }
                
                Button("대화 신고하기", role: .destructive) {
                    isFlagSheetVisible = true
                }
            }
            .sheet(isPresented: $isFlagSheetVisible) {
                if let opponent = opponent {
                    MessageFlagSheet(
                        conversationId: conversation.id,
                        messageId: nil,
                        userId: opponent.user.id
                    ) {
                        isFlagSheetVisible = false
                    } submitAction: { _ in
                        isFlagSheetVisible = false
                    }
                } else {
                    EmptyView()
                }
            }
    }
}

fileprivate extension DirectMessageConversation {
    func unreadCount(for userId: String) -> Int {
        return participants.first { $0.user.id == userId }?.unread_count ?? 0
    }
    
    var displayText: String {
        guard let latestMessage = latest_message else {
            return ""
        }
        
        switch latestMessage.content.type {
        case "text":
            return latestMessage.content.text ?? ""
        case "attachment":
            return "📎 이미지를 보냈습니다."
        default:
            return ""
        }
    }
    
    var displayRelativeTime: String {
        guard let sentAt = latest_message?.created_at.asISO8601Date else {
            return ""
        }
        
        
        return sentAt.relativeTime
    }
    
}

#Preview {
    let userSelf = DirectMessageParticipant(user: .mock1,
                                            read_at: "2020-04-01T00:00:00Z",
                                            unread_count: 3)
    
    let userOther = DirectMessageParticipant(user: .mock0,
                                             read_at: "2020-04-01T00:00:00Z")
    
    
    let latest_message_1 = DirectMessage(id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                                         sender: "other",
                                         content: DirectMessageContent(type: "text",
                                                                       text: "메로스는 격노했다. 기필코 저 포악하기 짝이 없는 왕을 없애겠다고 결의했다. 메로스는 정치를 알지 못한다. 메로스는 마을의 양치기에 지나지 않으니까. 피리를 불며 양과 놀며 지내왔다. 그럼에도 사악한 것에는 다른 사람보다 더욱 민감하였다."),
                                         created_at: "1970-01-01T00:00:00Z")
    
    let latest_message_2 = DirectMessage(id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385416")!,
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
    
    
    ConversationListItem(conversation: conversation1)
    ConversationListItem(conversation: conversation2)
}
