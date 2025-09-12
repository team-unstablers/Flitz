//
//  CardFlagSheet.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

class FZIntermediateUserFlag: ObservableObject {
    @Published
    var reasonInappropriateProfile: Bool = false
    
    @Published
    var reasonImpersonation: Bool = false
    
    @Published
    var reasonIllegalContents: Bool = false
    
    @Published
    var reasonMinor: Bool = false
    
    @Published
    var reasonOther: Bool = false
    
    @Published
    var feedbackText: String = ""
    
    func validate() -> Bool {
        return reasonInappropriateProfile || reasonImpersonation || reasonIllegalContents || reasonMinor || (reasonOther && !feedbackText.isEmpty)
    }
    
    func reasons() -> Set<FlagUserReason> {
        var result = Set<FlagUserReason>()
        
        if reasonInappropriateProfile {
            result.insert(.inappropriateProfile)
        }
        
        if reasonImpersonation {
            result.insert(.impersonation)
        }
        
        if reasonIllegalContents {
            result.insert(.illegalContents)
        }
        
        if reasonMinor {
            result.insert(.minor)
        }
        
        if reasonOther {
            result.insert(.other)
        }
        
        return result
    }
}

struct UserFlagSheet: View {
    @State
    var busy: Bool = false
    
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var intermediate = FZIntermediateUserFlag()
    
    @State
    var blockImmediately: Bool = true

    let userId: String
    
    var dismissAction: () -> Void
    var submitAction: (Bool) -> Void
    
    @FocusState
    var isFeedbackTextFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text(NSLocalizedString("ui.safety.flag.what_problem", comment: "어떤 문제가 있었나요?").byCharWrapping)
                        .font(.fzHeading1)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(NSLocalizedString("ui.safety.flag.problem_description", comment: "어떤 문제가 있었는지 알려주시면, Flitz 팀에서 빠르게 조치할 수 있어요.").byCharWrapping)
                        .font(.fzMain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)


                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Toggle(isOn: $intermediate.reasonInappropriateProfile) {
                                Text(NSLocalizedString("ui.safety.report.inappropriate_profile", comment: "프로필 이미지나 프로필 내용이 부적절해요"))
                            }
                            
                            Toggle(isOn: $intermediate.reasonImpersonation) {
                                Text(NSLocalizedString("ui.safety.report.impersonation", comment: "다른 사람을 사칭하거나 도용하고 있어요"))
                            }

                            Toggle(isOn: $intermediate.reasonIllegalContents) {
                                Text(NSLocalizedString("ui.safety.report.illegal_contents", comment: "불법 행위를 제안하거나 조장하고 있어요 (예: 마약, 성매매 등)"))
                            }

                            Toggle(isOn: $intermediate.reasonMinor) {
                                Text(NSLocalizedString("ui.safety.report.minor", comment: "미성년자 또는 청소년이 이 앱을 사용하고 있어요"))
                            }

                            Toggle(isOn: $intermediate.reasonOther) {
                                Text(NSLocalizedString("ui.safety.report.other_problem", comment: "그 외 다른 문제가 있어요 (아래에 상세히 적어주세요)"))
                            }
                        }
                        .toggleStyle(FZCheckboxToggleStyle())
                        
                        TextField(NSLocalizedString("ui.safety.flag.additional_feedback", comment: "필요한 경우 추가적인 내용을 적어주세요.").byCharWrapping, text: $intermediate.feedbackText, axis: .vertical)
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
                        
                        Toggle(isOn: $blockImmediately) {
                            Text(NSLocalizedString("ui.safety.flag.block_immediately", comment: "신고 후 이 사용자를 곧바로 차단할래요"))
                        }
                        .toggleStyle(FZCheckboxToggleStyle())

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(busy)
                }
                .padding()
            }
            .onTapGesture {
                isFeedbackTextFocused = false
            }
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationTitle(NSLocalizedString("ui.safety.title.report_user", comment: "사용자 신고하기"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("ui.safety.action.cancel", comment: "취소")) {
                        dismissAction()
                    }
                    .disabled(busy)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("ui.safety.action.send_report", comment: "신고 보내기"), role: .destructive) {
                        Task {
                            await performPost()
                        }
                    }
                    .bold()
                    .disabled(!intermediate.validate() || busy)
                }
            }
        }
    }
    
    @MainActor
    func performPost() async {
        busy = true
        
        defer {
            busy = false
        }
        
        let client = appState.client
        
        do {
            let args = FlagUserArgs(
                message: nil,
                reason: Array(intermediate.reasons()),
                user_description: intermediate.feedbackText
            )
            
            let response = try await client.flagUser(id: userId, args: args)
        } catch {
            print(error)
        }
        
        if blockImmediately {
            do {
                try await client.blockUser(id: userId)
            } catch {
                print(error)
            }
        }
        
        submitAction(blockImmediately)
    }
}

#Preview {
    VStack {
        
    }.sheet(isPresented: .constant(true)) {
        UserFlagSheet(userId: "12345") {
            
        } submitAction: { blocked in
            
        }
        .environmentObject(RootAppState())
    }
}
