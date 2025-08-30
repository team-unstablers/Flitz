//
//  SignInScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

enum SignUpPhase {
    case agreement
    
    case phoneNumberVerification
    case krPhoneNumberVerification
    
    case identity
    case createProfile
    case credentials
}

enum SignUpError: LocalizedError {
    case tokenValidationFailed
    
    var errorDescription: String? {
        switch self {
        case .tokenValidationFailed:
            return NSLocalizedString("fzapi.signup.token_validation_failed", comment: "회원 가입에는 성공했지만 토큰 검증에 실패했어요. (휴대폰 시간이 너무 늦거나 빠른가요?)")
        }
    }
}

@MainActor
class FZIntermediateCredential: ObservableObject {
    var client: FZAPIClient? = nil
    
    @Published
    var username: String = "" {
        didSet {
            validateUsername()
        }
    }
    
    @Published
    var password: String = "" {
        didSet {
            validatePassword()
        }
    }
     
    @Published
    var confirmPassword: String = "" {
        didSet {
            validatePassword()
        }
    }
    
    @Published
    var usernameError: FZFormError? = nil
    
    @Published
    var passwordError: FZFormError? = nil
    
    @Published
    var confirmPasswordError: FZFormError? = nil
    
    var usernameValidationTask: Task<Void, Never>? = nil
    
    func validateUsername() {
        let cleanUsername = username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            // remove non-alphanumeric characters except underscore
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
        
        defer {
            self.objectWillChange.send()
        }

        if cleanUsername.isEmpty {
            usernameError = .required
            return
        }
        

        usernameError = .checkInProgress
        
        self.usernameValidationTask?.cancel()
        self.usernameValidationTask = Task {
            
            guard let client = self.client else {
                DispatchQueue.main.async {
                    self.usernameError = .notAcceptable
                    self.objectWillChange.send()
                }
                return
            }
            
            do {
                let result = try await client.registrationUsernameAvailability(username: cleanUsername)
                
                DispatchQueue.main.async {
                    if result.is_success {
                        self.usernameError = nil
                    } else {
                        self.usernameError = .notAcceptable
                    }
                    
                    self.objectWillChange.send()
                }
            } catch {
                // TODO: log to sentry
                print(error)
                DispatchQueue.main.async {
                    self.usernameError = .notAcceptable
                    self.objectWillChange.send()
                }
            }
        }
        
        if (cleanUsername != username) {
            self.username = cleanUsername
        }
    }
    
    func validatePassword() {
        defer {
            self.objectWillChange.send()
        }
        
        guard password.count >= 8 else {
            self.passwordError = .tooShort(minLength: 8)
            return
        }
        
        // password must include at least one number and one special character
        guard password.filter({ $0.isNumber }).count > 0,
              password.filter({ $0.isPunctuation || $0.isSymbol }).count > 0
        else {
            self.passwordError = .passwordNotStrongEnough
            return
        }
        
        self.passwordError = nil
        
        if password != confirmPassword {
            self.confirmPasswordError = .passwordNotEqual
        } else {
            self.confirmPasswordError = nil
        }
    }
}

@MainActor
class SignUpViewModel: ObservableObject {
    let client = FZAPIClient(context: .load())
    
    var authPhaseState: AuthPhaseState? = nil
    
    @Published
    var busy: Bool = false
    
    @Published
    var shouldPresentError: Bool = false
    
    @Published
    var errorMessage: String = ""
    
    @Published
    var phase: [SignUpPhase] = []
    
    @Published
    var countryCode: CountryCode = .KR
    
    @Published
    var turnstileNonce = UUID()
    
    @Published
    var turnstileToken: String = ""
    
    @Published
    var agreeToPrivacyPolicy: Bool = false

    @Published
    var agreeToTerms: Bool = false
    
    @Published
    var agreeToLocationServiceTerms: Bool = false

    @Published
    var agreeToMarketingNotifications: Bool = false
    
    @Published
    var intermediate: FZIntermediateUser = FZIntermediateUser()
    
    @Published
    var intermediateCredential: FZIntermediateCredential = FZIntermediateCredential()
    
    func configure(with authPhaseState: AuthPhaseState) {
        self.authPhaseState = authPhaseState
    }
    
    func startSession() async {
        if busy {
            return
        }
        
        busy = true
        defer { busy = false }
        
        let args = StartRegistrationSessionArgs(
            country_code: countryCode.rawValue,
            agree_marketing_notifications: agreeToMarketingNotifications,
            device_info: FZAPIClient.userAgent,
            apns_token: AppDelegate.apnsToken,
            turnstile_token: turnstileToken
        )
        
        do {
            let session = try await client.startRegistration(args)
            client.context.token = session.token
            client.context.valid()
            
            self.intermediateCredential.client = client

            if countryCode == .KR {
                phase.append(.krPhoneNumberVerification)
            } else {
                phase.append(.phoneNumberVerification)
            }
        } catch {
            // sentry
            
            self.errorMessage = error.localizedDescription
            self.shouldPresentError = true
        }
    }
    
    func startKRPhoneVerification() async -> (String, String, String)? {
        if busy {
            return nil
        }
        
        busy = true
        defer { busy = false }
        
        let args = RegistrationStartPhoneVerificationArgs(phone_number: nil)
        
        do {
            let response = try await client.registrationStartPhoneVerification(args)
            
            guard let nicePayload = response.additional_data?["nice_payload"],
                  let hmac = response.additional_data?["nice_hmac"],
                  let niceTokenVersionId = response.additional_data?["nice_token_version_id"]
            else {
                throw FZAPIError.invalidResponse
            }
            
            return (nicePayload, hmac, niceTokenVersionId)
        } catch {
            // sentry
            
            self.errorMessage = error.localizedDescription
            self.shouldPresentError = true
            
            return nil
        }
    }
    
    func completeKRPhoneVerification(_ args: RegistrationCompletePhoneVerificationArgs) async {
        if busy {
            return
        }
        
        busy = true
        defer { busy = false }
        
        do {
            _ = try await client.registrationCompletePhoneVerification(args)
            phase.append(.identity)
        } catch {
            // sentry
            
            self.errorMessage = error.localizedDescription
            self.shouldPresentError = true
        }
    }
    
    func performSignUp() async {
        if busy {
            return
        }
        
        busy = true
        defer { busy = false }
        
        let registrationArgs = UserRegistrationArgs(
            username: intermediateCredential.username,
            password: intermediateCredential.password,
            display_name: intermediate.displayName,
            title: intermediate.title,
            bio: intermediate.bio,
            hashtags: intermediate.hashtags
        )
        
        do {
            let token = try await client.completeRegistration(with: registrationArgs)
            
            var newContext = FZAPIContext()
            
            newContext.token = token.token
            newContext.refreshToken = token.refresh_token
            
            guard newContext.valid() else {
                throw SignUpError.tokenValidationFailed
            }
            
            newContext.save()

            let newClient = FZAPIClient(context: newContext)
            
            let identityArgs = FZUserIdentity(
                gender: intermediate.gender.asBitMaskValue,
                is_trans: intermediate.isTransgender,
                display_trans_to_others: intermediate.transVisibleToOthers,
                preferred_genders: intermediate.preferredGender.reduce(0) { $0 | $1.asBitMaskValue },
                welcomes_trans: intermediate.isTransPreferred,
                trans_prefers_safe_match: intermediate.enableTransSafeMatch
            )
        
            _ = try await newClient.patchSelfIdentity(identityArgs)
            
            
            guard let pendingImage = intermediate.pendingProfileImage else {
                return
            }
            
            let imageData = pendingImage.jpegData(compressionQuality: 0.9)
            guard let data = imageData else {
                throw NSError(domain: "ProfileEditViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
            }
            
            try await newClient.setProfileImage(file: data, fileName: "image.jpg", mimeType: "image/jpeg")
        } catch {
            // TODO: sentry
            
            self.errorMessage = error.localizedDescription
            self.shouldPresentError = true
        }
        
    }
    
}

struct SignUpPhases {
    struct CountrySelectionScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        var body: some View {
            VStack {
                Text("Flitz는 현재 대한민국에서만 사용할 수 있어요.")
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    .padding(.bottom, 60)
                
                Picker("국가 선택", selection: $viewModel.countryCode) {
                        ForEach(CountryCode.allCases, id: \.self) {
                            Text($0.displayName)
                                .tag($0.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                
                Spacer()
                
                FZButton(size: .large) {
                    viewModel.phase.append(.agreement)
                } label: {
                    Text("다음")
                        .font(.fzMain)
                        .semibold()
                }
                .disabled(viewModel.countryCode != .KR)
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("국가 선택")
        }
    }
    
    struct AgreementScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        var body: some View {
            VStack {
                Text("Flitz를 사용하려면 아래 약관에 동의해야 해요.".byCharWrapping)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 60)
                
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Toggle(isOn: $viewModel.agreeToTerms) {
                            Text(LocalizedStringKey("ui.auth.signup.agreement.agree_terms"))
                                .tint(.blue)
                        }

                        Toggle(isOn: $viewModel.agreeToPrivacyPolicy) {
                            Text(LocalizedStringKey("ui.auth.signup.agreement.agree_privacy_policy"))
                                .tint(.blue)
                        }
                        
                        Toggle(isOn: $viewModel.agreeToLocationServiceTerms) {
                            Text(LocalizedStringKey("ui.auth.signup.agreement.agree_location_service_terms"))
                                .tint(.blue)
                        }
                        
                        // optional
                        Toggle(isOn: $viewModel.agreeToMarketingNotifications) {
                            Text(LocalizedStringKey("ui.auth.signup.agreement.agree_marketing_notifications"))
                        }
                    }
                    .toggleStyle(FZCheckboxToggleStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
                
                CFTurnstile(action: "register", nonce: viewModel.turnstileNonce) { token in
                    viewModel.turnstileToken = token
                }
                
                Spacer()
                
                FZButton(size: .large) {
                    Task {
                        await viewModel.startSession()
                    }
                } label: {
                    if viewModel.busy {
                        ProgressView()
                    } else {
                        Text("다음")
                            .font(.fzMain)
                            .semibold()
                    }
                }
                .disabled(viewModel.busy || !validated)
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("약관 동의")
        }
        
        var validated: Bool {
            return (
                viewModel.agreeToTerms &&
                viewModel.agreeToPrivacyPolicy &&
                viewModel.agreeToLocationServiceTerms &&
                
                viewModel.turnstileToken.count > 0
            )
        }
    }
    
    struct KRPhoneNumberVerificationScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        @State
        var nicePayload: String = ""
        
        @State
        var hmac: String = ""
        
        @State
        var niceTokenVersionId: String = ""
        
        @State
        var shouldPresentNiceWebView: Bool = false
        
        var body: some View {
            VStack {
                Text("휴대폰 인증을 통한 본인 확인을 진행해요.\n대한민국에서는 NICE 평가정보의 휴대폰 인증 서비스를 이용해요.".byCharWrapping)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    .padding(.bottom, 60)
                            
                Spacer()
                FZButton(size: .large) {
                    Task {
                        guard let result = await viewModel.startKRPhoneVerification() else {
                            return
                        }
                        
                        self.nicePayload = result.0
                        self.hmac = result.1
                        self.niceTokenVersionId = result.2
                        
                        self.shouldPresentNiceWebView = true
                    }
                } label: {
                    if viewModel.busy {
                        ProgressView()
                    } else {
                        Text("휴대폰 인증하기")
                            .font(.fzMain)
                            .semibold()
                    }
                }
                .disabled(viewModel.busy)
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("휴대폰 인증")
            .sheet(isPresented: $shouldPresentNiceWebView) {
                NavigationView {
                    NicePhoneVerification(
                        payload: nicePayload,
                        hmac: hmac,
                        tokenVersionId: niceTokenVersionId
                    ) { args in
                        guard let args = args else {
                            DispatchQueue.main.async {
                                self.viewModel.errorMessage = "휴대폰 인증이 올바르게 완료되지 않았어요. 다시 시도해 주세요."
                                self.viewModel.shouldPresentError = true
                                self.shouldPresentNiceWebView = false
                            }
                            return
                        }
                        
                        Task {
                            await viewModel.completeKRPhoneVerification(args)
                        }
                        self.shouldPresentNiceWebView = false
                    }
                    .navigationTitle("휴대폰 인증")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                self.shouldPresentNiceWebView = false
                            }
                        }
                    }
                }
                
            }
        }
    }

    struct UserIdentityScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack {
                        Text("Flitz에서 당신을 다른 사람들과 이어주기 위해 알아야 해요.")
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                            .padding(.bottom, 60)
                        
                        
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
                        .padding(.bottom, 8)
                        
                        ProfileIdentityNote()
                    }
                }
                
                VStack {
                    FZButton(size: .large) {
                        viewModel.phase.append(.createProfile)
                    } label: {
                        Text("다음")
                            .font(.fzMain)
                            .semibold()
                    }
                }
            }
            .safeAreaPadding(.horizontal)
            .safeAreaPadding(.bottom)
            .navigationTitle("당신은 어떤 사람인가요?")
        }
    }
    
    struct CreateProfileScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack {
                        Text("프로필을 입력해 주세요.\n다른 사용자들이 불쾌해 할 수 있는 내용은 입력하지 말아주세요.".byCharWrapping)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                            .padding(.bottom, 60)
                        
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
                    }
                }
                VStack {
                    FZButton(size: .large) {
                        viewModel.phase.append(.credentials)
                    } label: {
                        Text("다음")
                            .font(.fzMain)
                            .semibold()
                    }
                    .padding(.vertical, 8)
                    .disabled(
                        !viewModel.intermediate.validationError.isValid
                    )
                }
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("프로필 정보 입력")
        }
    }
    
    struct CredentialsScreen: View {
        @EnvironmentObject
        var viewModel: SignUpViewModel
        
        var signUpCompletionHandler: () -> Void

        var body: some View {
            VStack {
                ScrollView {
                    VStack {
                        Text("앱을 로그인할 때 사용할 인증 정보를 입력해 주세요.".byCharWrapping)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                            .padding(.bottom, 60)
                        
                        VStack(spacing: 40) {
                            FZInlineEntry("유저네임", error: viewModel.intermediateCredential.usernameError) {
                                TextField("유저네임을 입력해 주세요", text: $viewModel.intermediateCredential.username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            FZInlineEntry("비밀번호", error: viewModel.intermediateCredential.passwordError) {
                                SecureField("비밀번호를 입력해 주세요", text: $viewModel.intermediateCredential.password)
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            FZInlineEntry("비밀번호 재입력", error: viewModel.intermediateCredential.confirmPasswordError) {
                                SecureField("비밀번호를 다시 한번 입력해 주세요", text: $viewModel.intermediateCredential.confirmPassword)
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                    }
                }
                VStack {
                    FZButton(size: .large) {
                        Task {
                            await viewModel.performSignUp()
                            DispatchQueue.main.async {
                                RootAppState.shared.reloadContext()
                                
                                signUpCompletionHandler()
                            }
                        }
                    } label: {
                        if viewModel.busy {
                            ProgressView()
                        } else {
                            Text("회원 가입 마치기")
                                .font(.fzMain)
                                .semibold()
                        }
                    }
                    .padding(.top, 8)
                    .disabled(viewModel.busy || !validated)
                }
            }
            .safeAreaPadding(.horizontal)
            .navigationTitle("잠깐! 마지막으로..")
        }
        
        var validated: Bool {
            return  viewModel.intermediateCredential.usernameError == nil &&
            viewModel.intermediateCredential.passwordError == nil &&
            viewModel.intermediateCredential.confirmPasswordError == nil &&
            !viewModel.intermediateCredential.username.isEmpty &&
            !viewModel.intermediateCredential.password.isEmpty &&
            !viewModel.intermediateCredential.confirmPassword.isEmpty
        }
    }
}


struct SignUpScreen: View {
    @EnvironmentObject
    var authPhaseState: AuthPhaseState
    
    @StateObject
    var viewModel = SignUpViewModel()
    
    var signUpCompletionHandler: () -> Void

    var body: some View {
        NavigationStack(path: $viewModel.phase) {
            SignUpPhases.CountrySelectionScreen()
                .navigationDestination(for: SignUpPhase.self) { phase in
                    switch phase {
                    case .agreement:
                        SignUpPhases.AgreementScreen()
                    case .phoneNumberVerification:
                        EmptyView()
                    case .krPhoneNumberVerification:
                        SignUpPhases.KRPhoneNumberVerificationScreen()
                            .navigationBarBackButtonHidden()
                    case .identity:
                        SignUpPhases.UserIdentityScreen()
                            .navigationBarBackButtonHidden()
                    case .createProfile:
                        SignUpPhases.CreateProfileScreen()
                    case .credentials:
                        SignUpPhases.CredentialsScreen {
                            signUpCompletionHandler()
                        }
                            .if(viewModel.busy) {
                                $0.navigationBarBackButtonHidden()
                            }
                    default:
                        EmptyView()
                    }
                    
                }
        }
        .environmentObject(viewModel)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .alert(isPresented: $viewModel.shouldPresentError) {
            Alert(title: Text("오류"),
                  message: Text(viewModel.errorMessage),
                  dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    SignUpScreen {
        
    }
        .environmentObject(AuthPhaseState())
}
