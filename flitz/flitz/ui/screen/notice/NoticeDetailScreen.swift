//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

struct NoticeDetailHeader: View {
    let title: String
    let createdAt: Date
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.byCharWrapping)
                    .font(.fzHeading3)
                    .foregroundStyle(Color.Brand.black0)
                    .semibold()
                    .lineLimit(1)
                
                Text(createdAt.localeDateString)
                    .font(.fzMain)
                    .foregroundStyle(Color.Grayscale.gray6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            
            Divider()
                .background(Color.Grayscale.gray2)
        }
    }
}

struct NoticeDetailScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    let noticeId: String
    
    @State
    var notice: Notice? = nil
    
    
    var body: some View {
        NavigationView {
            if let notice = notice {
                VStack(spacing: 0) {
                    NoticeDetailHeader(title: notice.title, createdAt: notice.parsedCreatedAt)
                    ScrollView {
                        Text(notice.markdownContent)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.main)
                            .foregroundStyle(Color.Brand.black0)
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .navigationTitle(NSLocalizedString("ui.notice.detail.page_title", comment: "공지사항"))
        .onAppear {
            Task {
                await fetchNotice()
            }
        }
    }
    
    @MainActor
    func fetchNotice() async {
        do {
            let notice = try await appState.client.notice(id: noticeId)
            self.notice = notice
        } catch {
            print("Failed to fetch notice: \(error)")
        }
    }
}

#Preview {
    NoticeDetailScreen(noticeId: "test")
        .environmentObject(RootAppState())
}

extension Notice {
    var parsedCreatedAt: Date {
        return created_at.asISO8601Date!
    }
    
    var markdownContent: AttributedString {
        return try! AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        ))
    }
}
