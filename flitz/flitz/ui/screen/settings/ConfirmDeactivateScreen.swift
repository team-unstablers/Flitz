//
//  ConfirmDeactivateScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

struct ConfirmDeactivateScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    private var busy = false
    
    @State
    private var errorMessage: String?
    
    @State
    var feedbackText: String = ""
    
    @State
    var agreeToTerms: Bool = false
    
    @State
    private var showPasswordAlert = false
    
    @State
    private var passwordInput = ""
    
    @FocusState
    var isFeedbackTextFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(
                            format: NSLocalizedString("ui.settings.deactivation.title", comment: "%@님, 정말 계정을 삭제하시겠어요?"),
                            appState.profile?.display_name ?? "사용자"
                        ).byCharWrapping)
                            .font(.fzHeading1)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(alignment: .top) {
                            Image("NoteIcon")
                                .padding(.top, 3)
                            Text(NSLocalizedString("ui.settings.deactivation.description", comment: "계정을 삭제하면 포토카드,메시지 등 기존의 모든 활동정보가 삭제됩니다. 계정 삭제후 7일동안 다시 가입을 할 수 없습니다.").byCharWrapping)
                                .font(.fzMain)
                                .foregroundStyle(Color.Grayscale.gray6)
                        }
                        
                        /*
                         // TODO: IAP 도입 후 Flitz Coin 소멸 관련 안내 필요
                         HStack(alignment: .top) {
                         Image("NoteIcon")
                         .padding(.top, 3)
                         Text("".byCharWrapping)
                         .font(.fzMain)
                         .foregroundStyle(Color.Grayscale.gray6)
                         }
                         */
                    }
                    .padding(.top, 40)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(
                            format: NSLocalizedString("ui.settings.deactivation.reason.title", comment: "%@님이 떠나시는 이유는 무엇인가요?"),
                            appState.profile?.display_name ?? "사용자"
                        ).byCharWrapping)
                            .font(.fzHeading2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 60)
                        Text(NSLocalizedString("ui.settings.deactivation.reason.description", comment: "그 동안 Flitz를 이용해 주셔서 감사합니다.\n사용자님이 느끼셨던 점을 저희에게 공유해주시면 더욱 좋은 서비스를 제공할 수 있도록 노력하겠습니다.").byCharWrapping)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        /*
                        Group {
                            Toggle(isOn: .constant(false)) {
                                Text("Flitz의 기능이 부족했어요")
                            }
                            
                            Toggle(isOn: .constant(false)) {
                                Text("앱이 너무 복잡했어요")
                            }
                            
                            Toggle(isOn: .constant(false)) {
                                Text("개인 정보 보호가 걱정되었어요")
                            }

                            Toggle(isOn: .constant(false)) {
                                Text("다른 이유가 있어요")
                            }
                            
                            Toggle(isOn: .constant(false)) {
                                Text("대답하고 싶지 않아요")
                            }
                        }
                        .toggleStyle(FZRadioToggleStyle())
                         */
                        
                        TextField(NSLocalizedString("ui.settings.deactivation.reason.placeholder", comment: "피드백을 남겨주세요. (번거로우시면 꼭 남겨주시지 않으셔도 괜찮아요!)").byCharWrapping, text: $feedbackText, axis: .vertical)
                            .focused($isFeedbackTextFocused)
                            .font(.fzMain)
                            .lineLimit(4...5)
                            .padding(12)
                            .cornerRadius(4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(isFeedbackTextFocused ? .black : Color.Grayscale.gray4, lineWidth: 1)
                                    .animation(.easeInOut, value: isFeedbackTextFocused)
                            }
                            .disabled(busy)
                    }
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
            VStack {
                Toggle(isOn: $agreeToTerms) {
                    Text(NSLocalizedString("ui.settings.deactivation.reason.confirmation", comment: "회원 탈퇴 안내 사항을 확인하였으며, 이에 동의합니다.").byCharWrapping)
                }
                    .toggleStyle(FZCheckboxToggleStyle())
                    .disabled(busy)
                
                FZButton(size: .large) {
                    showPasswordAlert = true
                } label: {
                    if busy {
                        ProgressView()
                    } else {
                        Text(NSLocalizedString("ui.settings.account.deactivate_button", comment: "회원 탈퇴하기"))
                            .font(.fzHeading3)
                            .semibold()
                    }
                }
                    .disabled(busy || !agreeToTerms)
            }
            .padding(16)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onTapGesture {
            isFeedbackTextFocused = false
        }
        .navigationTitle(NSLocalizedString("ui.settings.deactivate.page_title", comment: "계정 삭제하기"))
        .navigationBarBackButtonHidden(busy)
        .alert("ui.settings.account.deactivate_password_alert.title", isPresented: $showPasswordAlert) {
            SecureField(NSLocalizedString("ui.settings.deactivate.textfield.password.placeholder", comment: ""), text: $passwordInput)
            Button(NSLocalizedString("ui.common.cancel", comment: "취소"), role: .cancel) {
                passwordInput = ""
            }
            Button(NSLocalizedString("ui.common.confirm", comment: "확인")) {
                Task {
                    await deactivateAccount(password: passwordInput)
                }
            }
        } message: {
            Text(NSLocalizedString("ui.settings.account.deactivate_password.message", comment: "계정을 비활성화하려면 계정 비밀번호를 입력해주세요."))
        }
    }
    
    @MainActor
    private func deactivateAccount(password: String) async {
        busy = true
        
        defer {
            busy = false
        }
        
        // 그냥 왠지 2초 정도 기다려주는게 좋을 것 같아서...
        try? await Task.sleep(for: .seconds(2))
        
        do {
            let client = appState.client
            
            let args = UserDeactivationArgs(
                password: password,
                feedback: feedbackText
            )
            let response = try await client.deactivateSelf(args)
            
            if !response.is_success {
                errorMessage = response.reason ?? NSLocalizedString("fzapi.unknown_error", comment: "알 수 없는 오류가 발생하였습니다")
                return
            }
            
            appState.logout()
            appState.navState.append(.deactivateCompleted)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


#Preview {
    ConfirmDeactivateScreen()
        .environmentObject(RootAppState())
}
