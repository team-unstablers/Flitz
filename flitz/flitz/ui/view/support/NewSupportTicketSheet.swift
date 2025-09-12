//
//  CardFlagSheet.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/22/25.
//

import SwiftUI

/**
 아 진짜... 나 너무 게으르다... ㅠㅠㅠ
 이렇게 살지 마쇼... ㅠ_ㅠ
 */
fileprivate enum __FIXME__NewSupportTicketFocusState: Hashable {
    case title
    case content
    case none
}

struct NewSupportTicketSheet: View {
    @State
    var busy: Bool = false
    
    @EnvironmentObject
    var appState: RootAppState
    
    @State
    var title: String = ""
    
    @State
    var content: String = ""
    
    var handler: () -> Void
    
    @FocusState
    private var focusState: __FIXME__NewSupportTicketFocusState?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    Text(NSLocalizedString("ui.support.new_ticket.title", comment: "새로운 문의 티켓 보내기").byCharWrapping)
                        .font(.fzHeading1)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(NSLocalizedString("ui.support.new_ticket.description", comment: "문의 내용을 보내주시면 최대한 빠르게 답변 드릴게요!").byCharWrapping)
                        .font(.fzMain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)


                    VStack(alignment: .leading, spacing: 16) {
                        TextField(NSLocalizedString("ui.support.new_ticket.title_placeholder", comment: "제목을 입력해주세요").byCharWrapping, text: $title)
                            .focused($focusState, equals: .title)
                            .font(.fzMain)
                            .padding(12)
                            .cornerRadius(4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(focusState == .title ? .black : Color.Grayscale.gray4, lineWidth: 1)
                                    .animation(.easeInOut, value: focusState)
                            }
                            .disabled(busy)
                        
                        TextField(NSLocalizedString("ui.support.new_ticket.content_placeholder", comment: "문의 내용을 입력해주세요").byCharWrapping, text: $content, axis: .vertical)
                            .focused($focusState, equals: .content)
                            .font(.fzMain)
                            .lineLimit(10...10)
                            .padding(12)
                            .cornerRadius(4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(focusState == .content ? .black : Color.Grayscale.gray4, lineWidth: 1)
                                    .animation(.easeInOut, value: focusState)
                            }
                            .disabled(busy)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(busy)
                }
                .padding()
            }
            .onTapGesture {
                focusState = nil
            }
            .toolbarVisibility(.visible, for: .navigationBar)
            .navigationTitle(NSLocalizedString("ui.support.new_ticket.page_title", comment: "새 문의 티켓"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("ui.support.ticket.cancel", comment: "취소")) {
                        handler()
                    }
                    .disabled(busy)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("ui.support.ticket.send", comment: "전송하기"), role: .destructive) {
                        Task {
                            await performPost()
                        }
                    }
                    .bold()
                    .disabled(title.isEmpty || content.isEmpty || busy)
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
            let args = SupportTicketArgs(
                title: title,
                content: content
            )
            
            let response = try await client.postSupportTicket(args)
        } catch {
            print(error)
        }
               
        handler()
    }
}

#Preview {
    VStack {
        
    }.sheet(isPresented: .constant(true)) {
        NewSupportTicketSheet {
            
        }
        .environmentObject(RootAppState())
    }
}
