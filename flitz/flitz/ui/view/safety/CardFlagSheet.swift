//
//  CardFlagSheet.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

class FZIntermediateCardFlag: ObservableObject {
    @Published
    var reasonOffensiveContents: Bool = false
    
    @Published
    var reasonPornographicContents: Bool = false
    
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
        return reasonOffensiveContents || reasonPornographicContents || reasonImpersonation || reasonIllegalContents || reasonMinor || (reasonOther && !feedbackText.isEmpty)
    }
    
    func reasons() -> Set<FlagCardReason> {
        var result = Set<FlagCardReason>()
        
        if reasonOffensiveContents {
            result.insert(.offensive)
        }
        
        if reasonPornographicContents {
            result.insert(.pornographic)
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

struct CardFlagSheet: View {
    @State
    var busy: Bool = false
    
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var intermediate = FZIntermediateCardFlag()
    
    @State
    var blockImmediately: Bool = true

    let cardId: String
    let userId: String
    
    var dismissAction: () -> Void
    var submitAction: (Bool) -> Void
    
    @FocusState
    var isFeedbackTextFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text("카드에 어떤 문제가 있었나요?".byCharWrapping)
                        .font(.fzHeading1)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("어떤 문제가 있었는지 알려주시면, Flitz 팀에서 빠르게 조치할 수 있어요.".byCharWrapping)
                        .font(.fzMain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)


                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Toggle(isOn: $intermediate.reasonOffensiveContents) {
                                Text("다른 사용자를 괴롭히거나, 공격적인 내용을 담고 있어요")
                            }
                            
                            Toggle(isOn: $intermediate.reasonPornographicContents) {
                                Text("음란물이나 성적 수치심을 주는 내용을 담고 있어요")
                            }
                            
                            Toggle(isOn: $intermediate.reasonImpersonation) {
                                Text("다른 사람을 사칭하거나 도용하고 있어요")
                            }
                            
                            Toggle(isOn: $intermediate.reasonIllegalContents) {
                                Text("불법 행위를 제안하거나 조장하고 있어요 (예: 마약, 성매매 등)")
                            }
                            
                            Toggle(isOn: $intermediate.reasonMinor) {
                                Text("미성년자 또는 청소년이 이 앱을 사용하고 있어요")
                            }

                            Toggle(isOn: $intermediate.reasonOther) {
                                Text("그 외 다른 문제가 있어요 (아래에 상세히 적어주세요)")
                            }
                        }
                        .toggleStyle(FZCheckboxToggleStyle())
                        
                        TextField("필요한 경우 추가적인 내용을 적어주세요.".byCharWrapping, text: $intermediate.feedbackText, axis: .vertical)
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
                            Text("신고 후 이 사용자를 곧바로 차단할래요")
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
            .navigationTitle("카드 신고하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismissAction()
                    }
                    .disabled(busy)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("신고 보내기", role: .destructive) {
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
            let args = FlagCardArgs(
                message: nil,
                reason: Array(intermediate.reasons()),
                user_description: intermediate.feedbackText
            )
            
            let response = try await client.flagCard(id: cardId, args: args)
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
        CardFlagSheet(cardId: "12345", userId: "1234") {
            
        } submitAction: { blocked in
            
        }
        .environmentObject(RootAppState())
    }
}
