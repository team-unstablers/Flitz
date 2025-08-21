//
//  PasswdScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/21/25.
//

import SwiftUI

@MainActor
class PasswdScreenViewModel: ObservableObject {
    @Published 
    var currentPassword: String = ""
    @Published 
    var newPassword: String = ""
    @Published 
    var confirmPassword: String = ""
    
    
    @Published
    var showErrorAlert: Bool = false

    @Published
    var errorMessage: String = ""
    
    func validate() -> Bool {
        guard !currentPassword.isEmpty else {
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
    
    func changePassword() async -> Bool {
        let client = RootAppState.shared.client
        
        do {
            let args = UserPasswdArgs(old_password: currentPassword, new_password: newPassword)
            let response = try await client.passwd(args)
            
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

struct PasswdScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel = PasswdScreenViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                FZInlineEntry("현재 비밀번호") {
                    SecureField("현재 비밀번호를 입력해 주세요", text: $viewModel.currentPassword)
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
        .padding()
        .navigationTitle("비밀번호 변경")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("변경") {
                    if !viewModel.validate() {
                    }
                    
                    Task {
                        if (await viewModel.changePassword()) {
                            _ = appState.navState.popLast()
                        }
                    }
                }
                .disabled(!viewModel.validate())
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("오류"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    ProtectionSettingsScreen()
        .environmentObject(RootAppState())
}
