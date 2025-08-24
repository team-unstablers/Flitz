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

    let message: DirectMessage
    let isFromCurrentUser: Bool
    let isRead: Bool
    
    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
            if isFromCurrentUser && isRead {
                Text("읽음")
            }
            Text(self.message.created_at.asISO8601Date?.localeTimeString ?? "")
        }
            .font(.caption2)
            .foregroundStyle(Color.Grayscale.gray7)
    }
    
}

struct MessageBubble: View {
    @Environment(\.conversationId)
    var conversationId: String
    
    let message: DirectMessage
    let isFromCurrentUser: Bool
    let isRead: Bool
    var onAttachmentTap: ((String) -> Void)? = nil
    
    @State
    var isFlagSheetVisible = false
    
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
                MessageMetadataIndicator(message: message, isFromCurrentUser: isFromCurrentUser, isRead: isRead)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                contentView
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .contextMenu {
                        if isFromCurrentUser {
                            Button("메시지 삭제", role: .destructive) {
                                /*
                                Task {
                                    await viewModel.deleteMessage(id: message.id.uuidString)
                                }
                                 */
                            }
                        } else {
                            Button("메시지 신고", role: .destructive) {
                                isFlagSheetVisible = true
                            }
                        }
                    }
            }
            
            if !isFromCurrentUser {
                MessageMetadataIndicator(message: message, isFromCurrentUser: isFromCurrentUser, isRead: isRead)
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $isFlagSheetVisible) {
            MessageFlagSheet(
                conversationId: conversationId,
                messageId: message.id.uuidString,
                userId: message.sender
            ) {
                isFlagSheetVisible = false
            } submitAction: { _ in
                isFlagSheetVisible = false
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch message.content.type {
        case "text":
            if let text = message.content.text {
                Text(text)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleColor)
            }
        case "attachment":
            if  let attachmentId = message.content.attachment_id,
                let urlString = message.content.thumbnail_url ?? message.content.public_url,
                let url = URL(string: urlString),
                let width = message.content.width,
                let height = message.content.height {
                let originalSize = CGSize(width: width, height: height)
                let scaledSize = originalSize.scaleInto(target: CGSize(width: 200, height: 200))
                
                VStack(spacing: 0) {
                    ThumbnailPreview(attachmentId: attachmentId, url: url, size: scaledSize)
                }
                    .frame(width: scaledSize.width, height: scaledSize.height)
                    .onTapGesture {
                        onAttachmentTap?(attachmentId)
                    }
            }
        default:
            Text("Unsupported message type")
        }
    }
}

struct ThumbnailPreview: View {
    let attachmentId: String
    let url: URL
    let size: CGSize
    
    var body: some View {
        CachedAsyncImage(url: url, identifier: "message:attachment:\(attachmentId)") { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: size.width, maxHeight: size.height)
        } placeholder: {
            ProgressView()
                .frame(width: size.width, height: size.height)
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
            isFromCurrentUser: true,
            isRead: true,
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
            isFromCurrentUser: false,
            isRead: true
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
            isFromCurrentUser: false,
            isRead: false
        )
    }
    .padding()
}


