//
//  ProfileImage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct SelfProfileImage: View {
    @EnvironmentObject
    var appState: RootAppState
    
    var size: CGFloat
    
    var body: some View {
        if let profile = appState.profile {
            ProfileImage(url: profile.profile_image_url, userId: profile.id, size: size)
        } else {
            ProgressView()
                .frame(width: size, height: size)
        }
    }
}

