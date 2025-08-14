//
//  ProfileScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/4/25.
//

import SwiftUI
import PhotosUI

import BrightroomEngine
import BrightroomUI

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
    
    var asBitMaskValue: Int {
        switch self {
        case .man:
            return 1
        case .woman:
            return 2
        case .nonBinary:
            return 4
        }
    }
    
    static func from(bitMaskValue: Int) -> FZIntermediateGenderSelection {
        switch bitMaskValue {
        case 1:
            return .man
        case 2:
            return .woman
        case 4:
            return .nonBinary
        default:
            return .nonBinary
        }
    }
}


class FZIntermediateUserValidationError: ObservableObject {
    @Published
    var displayName: FZFormError? = nil
    
    @Published
    var title: FZFormError? = nil
    
    @Published
    var bio: FZFormError? = nil
    
    var isValid: Bool {
        return displayName == nil && title == nil && bio == nil
    }
}


class FZIntermediateUser: ObservableObject {
    @Published
    var displayName: String = "" {
        didSet {
            validate()
        }
    }
    
    @Published
    var title: String = "" {
        didSet {
            validate()
        }
    }
    
    @Published
    var bio: String = "" {
        didSet {
            validate()
        }
    }
    
    @Published
    var birthDate: Date = Date()
    
    @Published
    var profileImageUrl: String? = nil
    
    @Published
    var pendingProfileImage: UIImage? = nil
    
    @Published
    var hashtags: [String] = []
    
    @Published
    var email: String = ""
    
    @Published
    var phoneNumber: String = ""

    @Published
    var gender: FZIntermediateGenderSelection = .nonBinary
    
    @Published
    var preferredGender: Set<FZIntermediateGenderSelection> = [.man, .nonBinary, .woman]
    
    @Published
    var isTransgender: Bool = false
    
    @Published
    var transVisibleToOthers: Bool = false
    
    @Published
    var isTransPreferred: Bool = false
    
    @Published
    var enableTransSafeMatch: Bool = false

    @Published
    var identifyValue: Double = 0.0
    
    @Published
    var preferredIdentifyRange: ClosedRange<Double> = -2...2
    
    @Published
    var validationError = FZIntermediateUserValidationError()
    
    
    init() {
        
    }
    
    func validate() {
        // @start displayName
        if displayName.isEmpty {
            validationError.displayName = .required
        } else if displayName.count > 16 {
            validationError.displayName = .tooLong(maxLength: 16)
        } else {
            validationError.displayName = nil
        }
        // @end displayName
        
        // @start title
        if title.isEmpty {
            validationError.title = .required
        } else if title.count > 16 {
            validationError.title = .tooLong(maxLength: 16)
        } else {
            validationError.title = nil
        }
        // @end title
        
        // @start bio
        if bio.isEmpty {
            validationError.bio = .required
        } else if bio.count > 240 {
            validationError.bio = .tooLong(maxLength: 240)
        } else {
            validationError.bio = nil
        }
        // @end bio
    }
    
    static func from(_ profile: FZSelfUser, _ identity: FZUserIdentity?) -> FZIntermediateUser {
        let intermediate = FZIntermediateUser()
        
        intermediate.displayName = profile.display_name
        intermediate.profileImageUrl = profile.profile_image_url
        
        intermediate.title = profile.title
        intermediate.bio = profile.bio
        intermediate.hashtags = profile.hashtags
        
        // FIXME
        intermediate.birthDate = Date()
        
        intermediate.email = profile.email ?? ""
        intermediate.phoneNumber = profile.phone_number ?? ""
        
        if let identity = identity {
            intermediate.gender = FZIntermediateGenderSelection.from(bitMaskValue: identity.gender)
            intermediate.isTransgender = identity.is_trans
            intermediate.transVisibleToOthers = identity.display_trans_to_others
            intermediate.preferredGender = Set([1, 2, 4].filter {
                identity.preferred_genders & $0 != 0
            }.map {
                FZIntermediateGenderSelection.from(bitMaskValue: $0)
            })
            intermediate.isTransPreferred = identity.welcomes_trans
            intermediate.enableTransSafeMatch = identity.trans_prefers_safe_match
        }
        
        
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
    
    @Published
    var busy = false
    
    func configure(with apiClient: FZAPIClient) {
        // Configure with API client if needed
        self.apiClient = apiClient
        
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        do {
            guard let profile = try await apiClient?.fetchSelf() else {
                // ?
                return
            }
            
            let identity = try? await apiClient?.selfIdentity()
            
            self.intermediate = FZIntermediateUser.from(profile, identity)
        } catch {
            // Handle error appropriately
        }
    }
    
    func saveProfileImage() async throws {
        defer { busy = false }
        busy = true

        guard let apiClient = apiClient,
              let pendingImage = intermediate.pendingProfileImage else {
            return
        }
        
        let imageData = pendingImage.jpegData(compressionQuality: 0.9)
        guard let data = imageData else {
            throw NSError(domain: "ProfileEditViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
        }
        
        try await apiClient.setProfileImage(file: data, fileName: "image.jpg", mimeType: "image/jpeg")
    }
    
    func saveProfile() async throws {
        defer { busy = false }
        busy = true

        guard let apiClient = apiClient else {
            return
        }
        
        let args = PatchSelfArgs(
            display_name: intermediate.displayName,
            title: intermediate.title,
            bio: intermediate.bio,
            hashtags: intermediate.hashtags
        )
        
        _ = try await apiClient.patchSelf(args)
        
        let identityArgs = FZUserIdentity(
            gender: intermediate.gender.asBitMaskValue,
            is_trans: intermediate.isTransgender,
            display_trans_to_others: intermediate.transVisibleToOthers,
            preferred_genders: intermediate.preferredGender.reduce(0) { $0 | $1.asBitMaskValue },
            welcomes_trans: intermediate.isTransPreferred,
            trans_prefers_safe_match: intermediate.enableTransSafeMatch
        )
        
        _ = try await apiClient.patchSelfIdentity(identityArgs)
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
    
    var error: FZFormError? = nil

    @ViewBuilder
    let content: () -> Content
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.Grayscale.gray6)
                    .font(.fzMain)

                if let error = error {
                    Text(error.message)
                        .foregroundStyle(.red)
                        .font(.fzSmall)
                }
            }
                .padding(.bottom, 6)

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfileEditSectionDivider: View {
    var body: some View {
        Divider()
            .background(Color.Grayscale.gray3)
    }
}

struct ProfileIdentityNote: View {
    var body: some View {
        VStack(alignment: .leading) {
            (Text(Image(systemName: "exclamationmark.triangle.fill")) + Text(" ") + Text("안내"))
                .font(.heading3)
                .bold()
                .foregroundStyle(.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            Group {
                Text("입력하신 정체성과 선호하는 사람들에 대한 정보는 공개되지 않으며, 매칭에만 사용돼요. 언제든지 바꿀 수 있어요.".byCharWrapping)
                Text("트랜스젠더 여부는 필터링이나 배제에 쓰이지 않아요.".byCharWrapping)
            }
            .font(.small)
            .foregroundStyle(.black.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.Grayscale.gray0.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}

struct ProfileEditImage: View {
    let url: String?
    let image: UIImage?
    
    let size: CGFloat
    var action: ((UIImage) -> Void)? = nil
    
    @State
    var selectedItems: [PhotosPickerItem] = []
    
    @State
    var editorContext: ImageEditorContext? = nil
    
    @State
    var editorVisible: Bool = false
    
    init(url: String?, size: CGFloat = 120, action: ((UIImage) -> Void)? = nil) {
        self.url = url
        self.image = nil
        
        self.size = size
        self.action = action
    }
    
    init(image: UIImage, size: CGFloat = 120, action: ((UIImage) -> Void)? = nil) {
        self.image = image
        self.url = nil
        
        self.size = size
        self.action = action
    }
    
    var body: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
            ZStack {
                if let url = url, let imageUrl = URL(string: url) {
                    CachedAsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    }
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                }
                
                Image("ProfileImageEditIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .padding(4)
                    .offset(x: size / 2 - 18, y: size / 2 - 18)
                
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await self.loadImage()
            }
        }
        .sheet(isPresented: $editorVisible) {
            if let editorContext = editorContext {
                NavigationStack {
                    VStack {
                        SwiftUICropView(editingStack: editorContext.editingStack, isAutoApplyEditingStackEnabled: true)
                            .croppingAspectRatio(PixelAspectRatio(width: 1, height: 1))
                    }
                    .navigationTitle("이미지 자르기")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("취소") {
                                editorVisible = false
                                self.editorContext = nil
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("저장") {
                                defer {
                                    editorVisible = false
                                    self.editorContext = nil
                                }
                                
                                do {
                                    try editorContext.render()
                                    guard let image = editorContext.rendered?.uiImage else {
                                        // TODO: Sentry.catch
                                        return
                                    }
                                    
                                    action?(image.resize(maxWidth: 768, maxHeight: 768))
                                } catch {
                                    // TODO: Sentry.catch
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func loadImage() async {
        guard let selectedItem = self.selectedItems.first else {
            return
        }
        
        
        guard let data = try? await selectedItem.loadTransferable(type: Data.self),
              let editorContext = try? await ImageEditorContext(from: data)
        else {
            return
        }
        
        self.editorContext = editorContext
        self.editorVisible = true
        
        selectedItems = []
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
                if let pendingImage = viewModel.intermediate.pendingProfileImage {
                    ProfileEditImage(image: pendingImage, size: 120) { newImage in
                        viewModel.intermediate.pendingProfileImage = newImage
                        viewModel.objectWillChange.send()
                    }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                } else {
                    ProfileEditImage(url: viewModel.intermediate.profileImageUrl, size: 120) { newImage in
                        viewModel.intermediate.pendingProfileImage = newImage
                        viewModel.objectWillChange.send()
                    }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                }
                
                VStack(alignment: .leading) {
                    ProfileEditSectionTitle("기본 정보")
                    ProfileEditSection {
                        ProfileEditSectionEntity(title: "닉네임", error: viewModel.intermediate.validationError.displayName) {
                            TextField("닉네임을 입력하세요", text: $viewModel.intermediate.displayName)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "한줄 칭호", error: viewModel.intermediate.validationError.title) {
                            TextField("당신을 나타내는 한줄 칭호!", text: $viewModel.intermediate.title)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()
                        
                        ProfileEditSectionEntity(title: "해시태그") {
                            FZHashtagField(hashtags: $viewModel.intermediate.hashtags)
                        }

                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "자기소개", error: viewModel.intermediate.validationError.bio) {
                            TextField("멋진 자기 소개를 입력해 보세요!", text: $viewModel.intermediate.bio, axis: .vertical)
                                .lineLimit(3...5)
                                .font(.fzHeading3)
                        }
                    }
                    
                    ProfileEditSectionTitle("중요 정보")
                    ProfileEditSection {
                        ProfileEditSectionEntity(title: "생년월일") {
                            TextField("TODO: date selector", text: $viewModel.intermediate.displayName)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()

                        ProfileEditSectionEntity(title: "이메일 주소") {
                            TextField("이메일 주소를 입력해 주세요", text: $viewModel.intermediate.email)
                                .font(.fzHeading3)
                        }
                        
                        ProfileEditSectionDivider()
                        
                        ProfileEditSectionEntity(title: "휴대폰 번호") {
                            TextField("휴대폰 번호를 입력해 주세요", text: $viewModel.intermediate.phoneNumber)
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
                                    Toggle(isOn: $viewModel.intermediate.transVisibleToOthers) {
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
                                 Toggle(isOn: $viewModel.intermediate.enableTransSafeMatch) {
                                    Text("안전한 사람들하고만 매칭할래요")
                                        .font(.fzMain)
                                }
                                .tint(Color.Pride.trans1)
                                .padding(.vertical, 4)
                                
                                if (viewModel.intermediate.enableTransSafeMatch) {
                                    Text("트랜스젠더를 환영한다고 밝힌 사람들하고만 매칭해요.")
                                        .font(.fzSmall)
                                }
                            } else {
                                Toggle(isOn: $viewModel.intermediate.isTransPreferred) {
                                    Text("트랜스젠더 사람들을 환영해요" + (viewModel.intermediate.isTransPreferred ? " 🙌🏳️‍⚧️🙌" : ""))
                                        .font(.fzMain)
                                }
                                .tint(Color.Pride.trans1)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                ProfileIdentityNote()
                .padding(.top, 12)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)

            }
            
        }
        .navigationTitle("프로필 설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.busy {
                    ProgressView()
                } else {
                    Button("저장") {
                        Task {
                            try? await viewModel.saveProfileImage()
                            try? await viewModel.saveProfile()
                            
                            appState.loadProfile()
                            
                            DispatchQueue.main.async {
                                appState.navState = []
                            }
                        }
                    }
                    .disabled(!viewModel.intermediate.validationError.isValid)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            viewModel.configure(with: appState.client)
        }
    }
}

#if DEBUG
class MockProfileEditViewModel: ProfileEditViewModel {
    override func loadProfile() async {
        let profile = FZSelfUser.mock1
        
        self.intermediate = FZIntermediateUser.from(profile, nil)
    }
}
#endif

#Preview {
    ProfileEditScreen(viewModel: MockProfileEditViewModel())
        .environmentObject(RootAppState())
}
