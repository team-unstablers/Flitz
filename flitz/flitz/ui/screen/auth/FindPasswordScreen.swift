//
//  PasswdScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/21/25.
//

import SwiftUI

@MainActor
class FindPasswordScreenViewModel: ObservableObject {
    @Published
    var currentPhase = 0
    
    @Published
    var busy = false
    
    @Published
    var username: String = ""
    
    @Published
    var phoneNumber: String = ""

    @Published
    var sessionId: String = ""

    @Published
    var verificationCode: String = ""
    
    @Published
    var newPassword: String = ""
    @Published 
    var confirmPassword: String = ""
    
    
    @Published
    var showErrorAlert: Bool = false

    @Published
    var errorMessage: String = ""
    
    func validatePhase0() -> Bool {
        guard !username.isEmpty else {
            return false
        }
        guard !phoneNumber.isEmpty else {
            return false
        }
        
        return true
    }
    
    func validate() -> Bool {
        guard !verificationCode.isEmpty else {
            return false
        }
        guard !newPassword.isEmpty else {
            return false
        }
        guard newPassword == confirmPassword else {
            return false
        }
        
        return true
    }
    
    func requestResetPassword() async {
        busy = true
        defer { busy = false }
       
        let client = FZAPIClient(context: FZAPIContext())
        
        do {
            let args = ResetPasswordRequestArgs(
                username: username,
                country_code: "KR",
                phone_number: phoneNumber
            )
            
            let response = try await client.requestPasswordReset(args)
            
            guard let sessionId = response.additional_data?["session_id"] else {
                errorMessage = response.reason ?? "알 수 없는 오류입니다."
                showErrorAlert = true
                return
            }
            
            self.sessionId = sessionId
            currentPhase = 1
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    func confirmResetPassword() async -> Bool {
        busy = true
        defer { busy = false }
        
        let client = FZAPIClient(context: FZAPIContext())

        do {
            let args = ResetPasswordConfirmArgs(
                session_id: sessionId,
                verification_code: verificationCode,
                new_password: newPassword
            )
            let response = try await client.confirmPasswordReset(args)
            
            if !response.is_success {
                errorMessage = response.reason ?? "알 수 없는 오류입니다."
                showErrorAlert = true
                
                return false
            }
            
            return true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            print("Error changing password: \(error)")
            return false
        }
    }
}

struct FindPasswordScreen: View {
    @EnvironmentObject
    var authPhaseState: AuthPhaseState

    @StateObject
    var viewModel = FindPasswordScreenViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                if viewModel.currentPhase == 0 {
                    VStack {
                        VStack(spacing: 40) {
                            FZInlineEntry("유저네임") {
                                TextField("유저네임을 입력해 주세요", text: $viewModel.username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            FZInlineEntry("휴대폰 번호") {
                                TextField("계정과 연결된 휴대폰 번호를 입력해 주세요", text: $viewModel.phoneNumber)
                                    .textContentType(.telephoneNumber)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 40) {
                        FZInlineEntry("인증번호") {
                            SecureField("문자로 수신받은 인증 번호를 입력해 주세요", text: $viewModel.verificationCode)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        FZInlineEntry("새 비밀번호") {
                            SecureField("새 비밀번호를 입력해 주세요", text: $viewModel.newPassword)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        FZInlineEntry("비밀번호 재입력") {
                            SecureField("비밀번호를 다시 한번 입력해 주세요", text: $viewModel.confirmPassword)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    }
                }
            }
            
            if viewModel.currentPhase == 0 {
                FZButton(size: .large) {
                    Task {
                        await viewModel.requestResetPassword()
                    }
                } label: {
                    if viewModel.busy {
                        ProgressView()
                    } else {
                        Text("인증 문자 받기")
                            .font(.fzHeading3)
                            .semibold()
                    }
                }
                .disabled(!viewModel.validatePhase0() || viewModel.busy)
            } else {
                FZButton(size: .large) {
                    Task {
                        _ = await viewModel.confirmResetPassword()
                        authPhaseState.navState = [.signIn]
                    }
                } label: {
                    if viewModel.busy {
                        ProgressView()
                    } else {
                        Text("비밀번호 변경하기")
                            .font(.fzHeading3)
                            .semibold()
                    }
                }
                .disabled(!viewModel.validate() || viewModel.busy)
            }
        }
        .padding()
        .navigationTitle("비밀번호 찾기")
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    FindPasswordScreen()
        .environmentObject(AuthPhaseState())
}
