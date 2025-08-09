//
//  ProfileScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

class FZIntermediateUser: ObservableObject {
    @Published
    var display_name: String = ""
    
    @Published
    var profile_image_url: String? = nil
    
    @Published
    var identifyValue: Double = 0.0
    
    @Published
    var preferredIdentifyRange: ClosedRange<Double> = -2...2
    
    init() {
        
    }
    
    static func from(_ profile: FZUser) -> FZIntermediateUser {
        let intermediate = FZIntermediateUser()
        
        intermediate.display_name = profile.display_name
        intermediate.profile_image_url = profile.profile_image_url
        
        return intermediate
    }
    
    
    
}

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Published
    var apiClient: FZAPIClient?
    
    // intermediate
    @Published
    var intermediate: FZIntermediateUser = FZIntermediateUser()
    
    func configure(with apiClient: FZAPIClient) {
        // Configure with API client if needed
        self.apiClient = apiClient
        
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        do {
            guard let profile = try await apiClient?.fetchUser(id: "self") else {
                // ?
                return
            }
            
            self.intermediate = FZIntermediateUser.from(profile)
        } catch {
            // Handle error appropriately
        }
    }
}

struct ProfileEditSectionTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.fzMain)
            .bold()
            .padding(.vertical, 8)
    }
}

struct ProfileEditSection<Content: View>: View {
    @ViewBuilder
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.Grayscale.gray3, lineWidth: 1)
        )
        .padding(.bottom, 20)
    }
}

struct ProfileEditSectionEntity<Content: View>: View {
    let title: String
    @ViewBuilder
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.fzMain)
                .foregroundStyle(Color.Grayscale.gray6)
                .padding(.bottom, 6)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct ProfileEditSectionDivider: View {
    var body: some View {
        Divider()
            .background(Color.Grayscale.gray3)
    }
}

struct ProfileEditScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel = ProfileEditViewModel()
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                ProfileImage(url: viewModel.intermediate.profile_image_url, size: 120)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading) {
                    ProfileEditSectionTitle("기본 정보")
                    ProfileEditSection {
                        ProfileEditSectionEntity(title: "닉네임") {
                            TextField("닉네임을 입력하세요", text: $viewModel.intermediate.display_name)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()
                        
                        ProfileEditSectionEntity(title: "해시태그") {
                            TextField("자기소개를 입력하세요", text: $viewModel.intermediate.display_name, axis: .vertical)
                                .lineLimit(2...3)
                                .font(.fzHeading3)
                        }

                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "자기소개") {
                            TextField("자기소개를 입력하세요", text: $viewModel.intermediate.display_name, axis: .vertical)
                                .lineLimit(3...5)
                                .font(.fzHeading3)
                        }
                    }
                    
                    ProfileEditSectionTitle("중요 정보")
                    ProfileEditSection {
                        ProfileEditSectionEntity(title: "생년월일") {
                            TextField("닉네임을 입력하세요", text: $viewModel.intermediate.display_name)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "이메일 주소") {
                            TextField("닉네임을 입력하세요", text: $viewModel.intermediate.display_name)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()
                        
                        ProfileEditSectionEntity(title: "휴대폰 번호") {
                            TextField("닉네임을 입력하세요", text: $viewModel.intermediate.display_name)
                                .font(.fzHeading3)
                        }
                    }
                    
                    ProfileEditSectionTitle("정체성 및 선호도")
                    
                    VStack {
                        Text("저는 제 자신을 다음과 같이 정의합니다:")
                        Slider(value: $viewModel.intermediate.identifyValue, in: -2...2, step: 1)
                        HStack {
                            switch( viewModel.intermediate.identifyValue) {
                            case -2:
                                Text("여성")
                            case -1:
                                Text("여성에 가까움")
                            case 0:
                                Text("중립")
                            case 1:
                                Text("남성에 가까움")
                            case 2:
                                Text("남성")
                            default:
                                Text("중립")
                            }
                        }
                        
                        ProfileEditSectionDivider()
                            .padding(.vertical, 8)
                        
                        Text("저는 아래 범위의 사람들과 연결되고 싶습니다:")
                            .padding(.bottom, 8)
                        ItsukiSlider(value: $viewModel.intermediate.preferredIdentifyRange, in: -2...2, step: 1, barStyle: (4, 8))
                        
                        HStack {
                            switch (viewModel.intermediate.preferredIdentifyRange.lowerBound) {
                            case -2:
                                Text("여성")
                            case -1:
                                Text("여성에 가까움")
                            case 0:
                                Text("중립")
                            case 1:
                                Text("남성에 가까움")
                            case 2:
                                Text("남성")
                            default:
                                Text("중립")
                            }
                            
                            Text("~")
                            
                            switch (viewModel.intermediate.preferredIdentifyRange.upperBound) {
                            case -2:
                                Text("여성")
                            case -1:
                                Text("여성에 가까움")
                            case 0:
                                Text("중립")
                            case 1:
                                Text("남성에 가까움")
                            case 2:
                                Text("남성")
                            default:
                                Text("중립")
                            }
                        }
                    }
                    .font(.fzMain)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading) {
                    (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text("안내"))
                        .font(.heading3)
                        .bold()
                        .foregroundStyle(.black.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    
                    Text("당신의 성 정체성이나 선호도에 대한 정보는 다른 사용자에게 공개되지 않습니다. 이 정보는 당신과 매칭되는 사람들을 찾기 위해 사용됩니다. 또한, 이 정보는 언제든지 수정할 수 있습니다.")
                    .font(.small)
                    .foregroundStyle(.black.opacity(0.8))
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.Grayscale.gray0.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 12)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            
        }
        .navigationTitle("프로필 설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    print("TODO: save profile")
                }
            }
        }
        .onAppear {
            viewModel.configure(with: appState.client)
        }
    }
}

#if DEBUG
class MockProfileEditViewModel: ProfileEditViewModel {
    override func loadProfile() async {
        let profile = FZUser(id: "test",
                             username: "cheesekun",
                             display_name: "cheesekun",
                             profile_image_url: "https://avatars.githubusercontent.com/u/964412?v=4")
        
        self.intermediate = FZIntermediateUser.from(profile)
    }
}
#endif

#Preview {
    ProfileEditScreen(viewModel: MockProfileEditViewModel())
        .environmentObject(RootAppState())
}
