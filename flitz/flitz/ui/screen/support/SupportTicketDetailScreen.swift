//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

struct SupportTicketDetailHeader: View {
    let title: String
    let createdAt: Date
    
    let displayUpperDivider: Bool
    
    init(title: String, createdAt: Date, displayUpperDivider: Bool = true) {
        self.title = title
        self.createdAt = createdAt
        self.displayUpperDivider = displayUpperDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if displayUpperDivider {
                Divider()
                    .background(Color.Grayscale.gray2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.byCharWrapping)
                    .font(.fzHeading3)
                    .foregroundStyle(Color.Brand.black0)
                    .semibold()
                    .lineLimit(1)
                
                Text(createdAt.localeDateString + " " + createdAt.localeTimeString)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            
            Divider()
                .background(Color.Grayscale.gray2)
        }
        .background(.white)
    }
}

struct SupportTicketDetailScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    let ticketId: String
    
    @State
    var ticket: SupportTicket? = nil
    
    @State
    var responses: [SupportTicketResponse] = []
    
    @State
    var busy = false
    
    @State
    var responseContent: String = ""
    
    @FocusState
    var isFocused: Bool
    
    var body: some View {
        NavigationView {
            if let ticket = ticket {
                ScrollView {
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        Section {
                            Text(ticket.markdownContent)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.main)
                                .foregroundStyle(Color.Brand.black0)
                        } header: {
                            SupportTicketDetailHeader(title: ticket.title, createdAt: ticket.parsedCreatedAt, displayUpperDivider: false)
                        }
                        
                        ForEach(0..<responses.count, id: \.self) { index in
                            let response = responses[index]
                            Section {
                                
                                Text(response.markdownContent)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.main)
                                    .foregroundStyle(Color.Brand.black0)
                            } header: {
                                let responderTitle = response.responder == "__USER__" ?
                                    "사용자님의 답변" :
                                    "Flitz 팀 \(response.responder)님의 답변"
                                
                                SupportTicketDetailHeader(title: responderTitle, createdAt: response.created_at.asISO8601Date!)
                            }
                        }
                        
                        Section {
                            VStack(spacing: 16) {
                                TextField("새로운 답변 추가하기...".byCharWrapping, text: $responseContent, axis: .vertical)
                                    .focused($isFocused)
                                    .font(.fzMain)
                                    .lineLimit(10...10)
                                    .padding(12)
                                    .cornerRadius(4)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(isFocused ? .black : Color.Grayscale.gray4, lineWidth: 1)
                                            .animation(.easeInOut, value: isFocused)
                                    }
                                    .disabled(busy)
                                
                                FZButton(size: .large) {
                                    Task {
                                        await postResponse()
                                    }
                                } label: {
                                    Text("답변 추가하기".byCharWrapping)
                                        .font(.fzHeading3)
                                        .semibold()
                                }
                                .disabled(responseContent.isEmpty || busy)
                            }
                                .padding(.horizontal, 16)
                        } header: {
                            VStack {
                                Divider()
                                    .background(Color.Grayscale.gray2)
                                
                                Text("새로운 답변 추가하기".byCharWrapping)
                                    .font(.fzHeading2)
                                    .foregroundStyle(Color.Brand.black0)
                                    .semibold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            
                        }
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .navigationTitle("ui.support.ticket_detail.title")
        .onAppear {
            Task {
                await fetchTicket()
            }
        }
    }
    
    @MainActor
    func fetchTicket() async {
        do {
            async let ticketTask = try await appState.client.supportTicket(id: ticketId)
            async let responsesTask = try await appState.client.supportTicketResponses(of: ticketId)
            
            let (ticket, responses) = try await (ticketTask, responsesTask)
            
            self.ticket = ticket
            self.responses = responses
        } catch {
            print("Failed to fetch support ticket: \(error)")
        }
    }
    
    @MainActor
    func postResponse() async {
        busy = true
        defer {
            busy = false
        }
        
        let client = appState.client
        
        do {
            try await client.postSupportTicketResponse(of: ticketId, SupportTicketResponseArgs(content: responseContent))
            responseContent = ""
        } catch {
            print("Failed to post support ticket response: \(error)")
        }
        
        
        await fetchTicket()
    }

}

/*
#Preview {
    SupportTicketDetailScreen(ticketId: "1")
        .environmentObject(RootAppState.shared)
}
 */

extension SupportTicket {
    var markdownContent: AttributedString {
        return try! AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))
    }
}

extension SupportTicketResponse {
    var markdownContent: AttributedString {
        return try! AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))
    }
}
