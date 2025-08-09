//
//  UserProfileModal.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/9/25.
//

import SwiftUI
import SwiftUIX

@MainActor
class UserProfileModalViewModel: ObservableObject {
    var apiClient: FZAPIClient? = nil
    var userId: String
    
    @Published
    var profile: FZUser? = nil
    
    init(userId: String) {
        self.userId = userId
    }
    
    func configure(with apiClient: FZAPIClient) {
        self.apiClient = apiClient
    }
    
    func loadProfile() async {
        guard let apiClient = apiClient else { return }
        
        do {
            self.profile = try await apiClient.fetchUser(id: userId)
        } catch {
            print("[UserProfileModalViewModel] Failed to load profile: \(error)")
        }
    }
}

struct UserProfileModalBackdrop: View {
    var body: some View {
        BlurEffectView(style: .regular)
            .edgesIgnoringSafeArea(.all)
    }
}

struct UserProfileModalDragArea: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.Grayscale.gray2)
                .frame(width: 40, height: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.vertical, 12)
        }
    }
}

struct UserProfileModalDistanceIndicator: View {
    var profile: FZUser
    
    var body: some View {
        VStack {
            Text("가까움")
                .font(.fzSmall)
                .foregroundStyle(Color(hex: 0x71CA68))
                .semibold()
        }
        .frame(width: 48, height: 24)
        .background(Color(hex: 0xA9D2A5, alpha: 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

}

struct UserProfileModalDivider: View {
    
    var body: some View {
        Divider()
            .background(Color.Grayscale.gray2)
            .padding(.vertical, 16)
    }

}

struct UserProfileModalSection<Content: View>: View {
    var title: String
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.fzSmall)
                .semibold()
                .padding(.bottom, 8)
            
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}


struct UserProfileModalProfileHeader: View {
    var profile: FZUser
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text(profile.display_name)
                    .font(.fzHeading2)
                    .bold()
                
                Spacer()
                
                UserProfileModalDistanceIndicator(profile: profile)
            }
                .padding(.bottom, 8)
            
            HStack(alignment: .center, spacing: 0) {
                Text("즐거운 여행자")
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
                
                Spacer()
                
                Text("2시간 전 온라인")
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
            }
            
        }
    }
}

struct UserProfileModalProfileImage: View {
    var url: String?
    var size: CGFloat = 56
    
    var body: some View {
        if let urlString = url,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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

struct UserProfileModalBody: View {
    var profile: FZUser
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ScrollView(.horizontal) {
                HStack {
                    if let profileImageUrl = profile.profile_image_url {
                        UserProfileModalProfileImage(url: profileImageUrl, size: 140)
                    }
                }
                .padding(16)
            }
            
            VStack(spacing: 0) {
                UserProfileModalDragArea()
                
                UserProfileModalProfileHeader(profile: profile)
                
                UserProfileModalDivider()
                
                UserProfileModalSection(title: "해시태그") {
                    Text(profile.hashtags.map { "#" + $0 }.joined(separator: " "))
                        .font(.fzMain)
                        .foregroundStyle(.blue.opacity(0.8))
                }

                UserProfileModalDivider()
                
                UserProfileModalSection(title: "자기 소개") {
                    Text("아마미 하루카 17살입니다! 노래와 과자를 좋아하는 것으로는, 누구한테도 지지 않아요♪ 아이돌로서는, 지금 좀 부족한 느낌이지만요… 진심으로 열심히 할 테니 잘 부탁드립니다!")
                        .font(.fzMain)
                }

            }
            .padding(.bottom, 16)
            .safeAreaPadding(.bottom)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .background(.white)
            .clipShape(PartRoundedRectangle(corners: [.topLeading, .topTrailing], cornerRadii: 20))
            .compositingGroup()
            .shadow(radius: 16)
        }
        .background(.red)
    }
}

struct UserProfileModal: View {
    @EnvironmentObject
    var appState: RootAppState

    var userId: String
    var onDismiss: (() -> Void)? = nil
    
    @StateObject
    var viewModel: UserProfileModalViewModel
    
    init(userId: String, onDismiss: (() -> Void)? = nil, viewModel: UserProfileModalViewModel? = nil) {
        self.userId = userId
        self.onDismiss = onDismiss
        
        self._viewModel = StateObject(wrappedValue: viewModel ?? UserProfileModalViewModel(userId: userId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            UserProfileModalBackdrop()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    onDismiss?()
                }
            
            if let profile = viewModel.profile {
                UserProfileModalBody(profile: profile)
            }
        }
        .onAppear {
            viewModel.configure(with: appState.client)
            
            Task {
                await viewModel.loadProfile()
            }
        }
    }
}

#if DEBUG

class UserProfileModalViewModelPreview: UserProfileModalViewModel {
    override func loadProfile() async {
        // Mock user data for preview
        self.profile = FZUser.mock1
    }
}

#endif

#Preview {
    ZStack {
        Text("test\ntest\ntest\ntest\ntest\ntest\ntest\ntest")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        UserProfileModal(userId: "test", viewModel: UserProfileModalViewModelPreview(userId: "test"))
            .environmentObject(RootAppState())
    }
}
