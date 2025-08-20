//
//  MessageListIem.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/1/25.
//

import SwiftUI

struct UserBlockItem: View {
    @Environment(\.userId)
    var userId: String
    
    var block: FZUserBlock
    
    var action: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                ProfileImage(url: block.blocked_user.profile_image_url)
                    .padding(.trailing, 4)
                VStack(alignment: .leading, spacing: 0) {
                    Text(block.blocked_user.display_name)
                        .font(.heading3)
                        .bold()
                        .lineLimit(1)
                }
            }
            Spacer()
            Button("차단 해제", role: .destructive) {
                action()
            }
        }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .overlay(Divider(), alignment: .bottom)
    }
}
