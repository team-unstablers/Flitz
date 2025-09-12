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
                FZInlineEntry(NSLocalizedString("ui.settings.password.textfield.currentpassword.label", comment: "")) {
                    SecureField(NSLocalizedString("ui.settings.passwd.textfield.current_password.placeholder", comment: ""), text: $viewModel.currentPassword)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                FZInlineEntry(NSLocalizedString("ui.settings.password.textfield.newpassword.label", comment: "")) {
                    SecureField(NSLocalizedString("ui.settings.passwd.textfield.new_password.placeholder", comment: ""), text: $viewModel.newPassword)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                FZInlineEntry(NSLocalizedString("ui.settings.password.textfield.confirmpassword.label", comment: "")) {
                    SecureField(NSLocalizedString("ui.settings.passwd.textfield.confirm_password.placeholder", comment: ""), text: $viewModel.confirmPassword)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
        }
        .padding()
        .navigationTitle(NSLocalizedString("ui.settings.change_password.page_title", comment: "비밀번호 변경"))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(NSLocalizedString("ui.settings.change_password.action.change", comment: "변경")) {
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
            Alert(title: Text(NSLocalizedString("ui.settings.account.error_alert_title", comment: "오류")), message: Text(viewModel.errorMessage), dismissButton: .default(Text(NSLocalizedString("ui.settings.account.error_alert_ok", comment: "확인"))))
        }
    }
}

#Preview {
    ProtectionSettingsScreen()
        .environmentObject(RootAppState())
}
