//
//  ProfileButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI

struct ProfileButton: View {
    var profile: FZSelfUser
    var handler: (() -> Void)? = nil
    
    var body: some View {
        Button {
            handler?()
        } label: {
            HStack(spacing: 12) {
                ProfileImage(
                    url: profile.profile_image_url,
                    userId: profile.id,
                    size: 60
                )
                
                VStack(alignment: .leading) {
                    (Text(profile.display_name).bold() + Text("  ›"))
                        .font(.fzHeading2)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
#if DEBUG
    let profile = FZSelfUser.mock1
    
    VStack {
        ProfileButton(profile: profile)
    }
    .padding(.horizontal, 16)
#endif
}
