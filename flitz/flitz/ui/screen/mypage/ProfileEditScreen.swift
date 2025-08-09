//
//  ProfileScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI

enum FZIntermediateGenderSelection: FZChipSelection {
    case man
    case woman
    case nonBinary
    
    var asLocalizedString: String {
        switch self {
        case .man:
            return "남성"
        case .woman:
            return "여성"
        case .nonBinary:
            return "논바이너리"
        }
    }
}

class FZIntermediateUser: ObservableObject {
    @Published
    var display_name: String = ""
    
    @Published
    var profile_image_url: String? = nil

    @Published
    var gender: FZIntermediateGenderSelection = .nonBinary
    
    @Published
    var preferredGender: Set<FZIntermediateGenderSelection> = [.man, .nonBinary, .woman]
    
    @Published
    var isTransgender: Bool = false
    
    @Published
    var comeOutOfCloset: Bool = false
    
    @Published
    var isTransgenderPreferred: Bool = false
    
    @Published
    var enableTransSafeMatching: Bool = false

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
                    ProfileEditSection {
                        ProfileEditSectionEntity(title: "정체성") {
                            FZSingleChipSelector(selectedChip: $viewModel.intermediate.gender)
                                .padding(.bottom, 8)
                            
                            Group {
                                Toggle(isOn: $viewModel.intermediate.isTransgender) {
                                    Text("트랜스젠더예요" + (viewModel.intermediate.isTransgender ? " 🙌🏳️‍⚧️🙌" : ""))
                                        .font(.fzMain)
                                }
                                .tint(Color.Pride.trans1)
                                
                                if viewModel.intermediate.isTransgender {
                                    Toggle(isOn: $viewModel.intermediate.comeOutOfCloset) {
                                        Text("트랜스젠더 여부를 프로필에 표시할래요")
                                            .font(.fzMain)
                                    }
                                    .tint(Color.Pride.trans2)
                                }
                            }
                                .padding(.vertical, 4)
                        }
                        
                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "선호하는 사람들") {
                            FZChipSelector(selectedChips: $viewModel.intermediate.preferredGender)
                            
                            if (viewModel.intermediate.isTransgender) {
                                 Toggle(isOn: $viewModel.intermediate.enableTransSafeMatching) {
                                    Text("안전한 사람들하고만 매칭할래요")
                                        .font(.fzMain)
                                }
                                .tint(Color.Pride.trans1)
                                .padding(.vertical, 4)
                                
                                if (viewModel.intermediate.enableTransSafeMatching) {
                                    Text("트랜스젠더를 환영한다고 밝힌 사람들하고만 매칭해요.")
                                        .font(.fzSmall)
                                }
                            } else {
                                Toggle(isOn: $viewModel.intermediate.isTransgenderPreferred) {
                                    Text("트랜스젠더 사람들을 환영해요" + (viewModel.intermediate.isTransgenderPreferred ? " 🙌🏳️‍⚧️🙌" : ""))
                                        .font(.fzMain)
                                }
                                .tint(Color.Pride.trans1)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading) {
                    (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text("안내"))
                        .font(.heading3)
                        .bold()
                        .foregroundStyle(.black.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    
                    Group {
                        Text("입력하신 정체성과 선호도는 공개되지 않으며, 매칭에만 사용돼요. 언제든지 바꿀 수 있어요.")
                        Text("트랜스젠더 여부는 필터링이나 배제에 쓰이지 않아요.")
                    }
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
