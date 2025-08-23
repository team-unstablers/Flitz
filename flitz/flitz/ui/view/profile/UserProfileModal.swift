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
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.4))
            // BlurEffectView(style: .regular)
        }
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

struct UserProfileModalDivider: View {
    
    var body: some View {
        Rectangle()
            .fill(Color.Grayscale.gray2)
            .frame(maxWidth: .infinity, maxHeight: 1)
            .padding(.vertical, 16)
            .background(.white) // BUG: safearea쯤으로 offset 내려가면 부모 배경이 투명해지는 문제 발생
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
        .background(.white) // BUG: safearea쯤으로 offset 내려가면 부모 배경이 투명해지는 문제 발생
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
                
                DistanceIndicator(distance: profile.fuzzy_distance)
            }
                .padding(.bottom, 8)
            
            HStack(alignment: .center, spacing: 0) {
                Text(profile.title)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
                
                Spacer()
                
                Text(profile.online_status.asLocalizedString)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
            }
            
        }
        .background(.white) // BUG: safearea쯤으로 offset 내려가면 부모 배경이 투명해지는 문제 발생
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


struct UserProfileModalMenuButton<Content: View>: View {
    var size: CGFloat = 36
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        Menu {
            content()
        } label: {
            VStack {
                Image("ECMenu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(width: size, height: size)
            .background(.white)
            .cornerRadius(size / 2)
            .compositingGroup()
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            .hapticFeedback()
        }
        .menuOrder(.fixed)
    }
}

class UserProfileModalBodyGeometryHelper: ObservableObject {
    @Published
    var size: CGSize = .zero
    
    @Published
    var profileImageAreaSize: CGSize = .zero
    
    @Published
    var contentAreaSize: CGSize = .zero
    
    @Published
    var opacity: Double = 1.0
}

struct UserProfileModalBody: View {
    var profile: FZUser
    
    var geometryHelper: UserProfileModalBodyGeometryHelper?

    var extraSpacing: CGFloat = 0
    var profileImageOpacity: Double = 1.0
    
    var onDismiss: (() -> Void)? = nil
    
    @State
    var isFlagSheetVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .bottom) {
                if let profileImageUrl = profile.profile_image_url {
                    UserProfileModalProfileImage(url: profileImageUrl, size: 140)
                }
                Spacer()
                UserProfileModalMenuButton() {
                    Button("사용자 신고하기", role: .destructive) {
                        isFlagSheetVisible = true
                    }
                    Button("사용자 차단하기", role: .destructive) {
                        Task {
                            await self.blockUser()
                            onDismiss?()
                        }
                    }
                }
            }
            .padding(16)
            .zIndex(2)
            .opacity(profileImageOpacity)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                geometryHelper?.profileImageAreaSize = size
            }

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    UserProfileModalDragArea()
                    UserProfileModalProfileHeader(profile: profile)
                }
                
                
                VStack(spacing: 0) {
                    UserProfileModalDivider()
                    
                    UserProfileModalSection(title: "해시태그") {
                        Text(profile.hashtags.map { "#" + $0 }.joined(separator: " "))
                            .font(.fzMain)
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                    
                    UserProfileModalDivider()
                    
                    UserProfileModalSection(title: "자기 소개") {
                        Text(profile.bio)
                            .font(.fzMain)
                    }
                }
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { size in
                    geometryHelper?.contentAreaSize = CGSize(width: size.width, height: size.height + 32)
                }
            }
            .padding(.bottom, 32)
            .padding(.bottom, extraSpacing)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .safeAreaPadding(.bottom)
            .background(.white)
            .clipShape(PartRoundedRectangle(corners: [.topLeading, .topTrailing], cornerRadii: 20))
            .compositingGroup()
            .shadow(radius: 16)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            geometryHelper?.size = size
        }
        .sheet(isPresented: $isFlagSheetVisible) {
            UserFlagSheet(userId: profile.id) {
                
            } submitAction: { blocked in
                
            }
        }
    }
    
    func blockUser() async {
        let client = RootAppState.shared.client
        
        do {
            try await client.blockUser(id: profile.id)
        } catch {
            print("[UserProfileModalBody] Failed to block user: \(error)")
        }
        
        // HACK: reset navigation state to close the modal
        RootAppState.shared.navState = []
    }
}

struct UserProfileModal: View {
    @EnvironmentObject
    var appState: RootAppState

    var userId: String
    var onDismiss: (() -> Void)? = nil
    
    @StateObject
    var viewModel: UserProfileModalViewModel
    
    @State private var dragOffset: CGSize = CGSize(width: 0, height: 300)
    @State private var opacity: Double = 0.0
    
    init(userId: String, onDismiss: (() -> Void)? = nil, viewModel: UserProfileModalViewModel? = nil) {
        self.userId = userId
        self.onDismiss = onDismiss
        
        self._viewModel = StateObject(wrappedValue: viewModel ?? UserProfileModalViewModel(userId: userId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            UserProfileModalBackdrop()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(opacity)
                .onTapGesture {
                    withAnimation {
                        self.dismiss()
                    }
                }
            
            if let profile = viewModel.profile {
                UserProfileModalBody(profile: profile,
                                     geometryHelper: nil,
                                     extraSpacing: max(0, -dragOffset.height),
                                     onDismiss: onDismiss)
                    .offset(y: max(0, dragOffset.height))
                    .opacity(opacity)
                    .gesture(
                        DragGesture()
                            /*
                            .updating($dragOffset) { value, state, txn in
                                if value.translation.height > 0 {
                                    state = value.translation
                                }
                            }
                             */
                            .onChanged { value in
                                if (value.translation.height > 0) {
                                    dragOffset = value.translation
                                } else {
                                    dragOffset = CGSize(width: 0, height: value.translation.height * 0.25)
                                }
                                
                                let progress = min(1.0, max(0, value.translation.height / 300))
                                opacity = 1.0 - (progress * 0.5)
                            }
                            .onEnded { value in
                                if value.translation.height > 150 {
                                    self.dismiss()
                                } else {
                                    withAnimation(.spring()) {
                                        opacity = 1.0
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .onAppear {
                        withAnimation(.spring()) {
                            opacity = 1.0
                            dragOffset = .zero
                        }
                    }

            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            viewModel.configure(with: appState.client)
            
            Task {
                await viewModel.loadProfile()
            }
        }
    }
    
    func dismiss() {
        withAnimation(.spring()) {
            opacity = 0
            dragOffset = CGSize(width: 0, height: 300)
        } completion: {
            onDismiss?()
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
