//
//  ProfileImage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

struct ProfileImage: View {
    var url: String?
    var identifier: String?
    
    var size: CGFloat = 56
    
    init(url: String?, size: CGFloat = 56) {
        self.url = url
        self.identifier = nil
        
        self.size = size
    }
    
    init(url: String?, userId: String, size: CGFloat = 56) {
        self.url = url
        self.identifier = "user:profile_image:\(userId)"
        
        self.size = size
    }
    
    var body: some View {
        if let urlString = url,
           let url = URL(string: urlString) {
            CachedAsyncImage(url: url, identifier: identifier) { image in
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay {
                        // TODO: dark mode면 white, light면 black.opacity(0.125)
                        Circle().stroke(.white.opacity(0.125))
                    }
                
            } placeholder: {
                ProgressView()
                    .frame(width: size, height: size)
            }
        } else {
            Image(systemName: "person")
                .frame(width: size, height: size)
        }
    }
}


#Preview {
    ProfileImage(url: nil, size: 60)
    
    ProfileImage(
        url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg",
        size: 36
    )
    
    ProfileImage(
        url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg",
        size: 72
    )
    
    ProfileImage(
        url: "https://ppiy.ac/system/accounts/avatars/110/796/233/076/688/314/original/df6e9ebf6bb70ef2.jpg",
        size: 128
    )
}
