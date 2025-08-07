//
//  MessageItem.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/2/25.
//

import SwiftUI

struct MessageMetadataIndicator: View {
    @Environment(\.userId)
    var userId: String

    @Environment(\.directMessageParticipants)
    var participants: [DirectMessageParticipant]
    
    let message: DirectMessage
    let isFromCurrentUser: Bool
    
    var createdAt: Date {
        get {
            return message.created_at.asISO8601Date ?? .init(timeIntervalSince1970: 0)
        }
    }
    
    var isRead: Bool {
        get {
            return participants.filter { $0.user.id != userId }.allSatisfy {
                guard let readAt = $0.read_at?.asISO8601Date else {
                    return false
                }
                
                return readAt >= createdAt
            }
        }
    }
    
    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
            if isFromCurrentUser && isRead {
                Text("읽음")
            }
            Text(self.createdAt.localeTimeString)
        }
            .font(.caption2)
            .foregroundStyle(Color.Grayscale.gray7)
    }
    
}

struct MessageBubble: View {
    let message: DirectMessage
    let isFromCurrentUser: Bool
    
    private var bubbleColor: Color {
        isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2)
    }
    
    private var bubbleAlignment: Alignment {
        isFromCurrentUser ? .trailing : .leading
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if isFromCurrentUser {
                Spacer()
                MessageMetadataIndicator(message: message, isFromCurrentUser: isFromCurrentUser)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                contentView
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if !isFromCurrentUser {
                MessageMetadataIndicator(message: message, isFromCurrentUser: isFromCurrentUser)
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch message.content.type {
        case "text":
            if let text = message.content.text {
                Text(text)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
            }
        case "attachment":
            if let url = message.content.thumbnail_url ?? message.content.public_url {
                ThumbnailPreview(url: url)
            }
        default:
            Text("Unsupported message type")
        }
    }
}

struct ThumbnailPreview: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 100, height: 100)
            @unknown default:
                EmptyView()
            }
        }
        /*
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
            .frame(width: 200, height: 150)
            .overlay(
                ProgressView()
                    .scaleEffect(0.8)
            )
         */
    }
}

#Preview {
    VStack(spacing: 16) {
        // 내가 보낸 텍스트 메시지
        MessageBubble(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "me",
                content: DirectMessageContent(
                    type: "text",
                    text: "안녕하세요! 반갑습니다 😊"
                ),
                created_at: "1970-01-01T00:00:00Z"
            ),
            isFromCurrentUser: true
        )
        
        // 상대방이 보낸 텍스트 메시지
        MessageBubble(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "text",
                    text: "네, 안녕하세요!"
                ),
                created_at: "1970-01-01T00:00:00Z"
            ),
            isFromCurrentUser: false
        )
        
        // 첨부파일이 있는 메시지
        MessageBubble(
            message: DirectMessage(
                id: UUID(uuidString: "9CBFEB0A-0883-4685-A2CB-6A21F5385415")!,
                sender: "other",
                content: DirectMessageContent(
                    type: "attachment",
                    attachment_type: "image",
                    public_url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg"
                ),
                created_at: "1970-01-01T00:00:00Z"
            ),
            isFromCurrentUser: false
        )
    }
    .padding()
}


