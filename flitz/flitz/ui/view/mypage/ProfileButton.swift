//
//  ProfileButton.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI

struct ProfileButton: View {
    var profile: FZUser
    var handler: (() -> Void)? = nil
    
    var body: some View {
        Button {
            handler?()
        } label: {
            HStack(spacing: 12) {
                ProfileImage(
                    url: profile.profile_image_url,
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
    let profile = FZUser(id: "test",
                         username: "cheesekun",
                         display_name: "cheesekun",
                         profile_image_url: "https://avatars.githubusercontent.com/u/964412?v=4")
    
    VStack {
        ProfileButton(profile: profile)
    }
    .padding(.horizontal, 16)
}
