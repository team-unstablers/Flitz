//
//  NoticeListScreen.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/17/25.
//

import SwiftUI

@MainActor
class NoticeListViewModel: ObservableObject {
    @Published
    var notices: [SimpleNotice] = []
    
    @Published
    var isLoading: Bool = false
    
    @Published
    var isLoadingMore: Bool = false
    
    private var currentPagination: Paginated<SimpleNotice>? = nil
    
    // This would typically be where you fetch the notices from an API or database.
    func fetchNotices() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let client = RootAppState.shared.client
        
        do {
            let pagination = try await client.noticeList()
            self.notices = pagination.results
            self.currentPagination = pagination
        } catch {
            #warning("잘못된 오류 처리")
            print("Failed to fetch notices: \(error)")
        }
    }
    
    func loadMore() async {
        guard !isLoadingMore,
              let currentPagination = currentPagination,
              currentPagination.next != nil else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        let client = RootAppState.shared.client
        
        do {
            if let nextPage = try await client.nextPage(currentPagination) {
                self.notices.append(contentsOf: nextPage.results)
                self.currentPagination = nextPage
            }
        } catch {
            #warning("잘못된 오류 처리")
            print("Failed to load more notices: \(error)")
        }
    }
}

struct NoticeListItem: View {
    let title: String
    let createdAt: Date
    
    let action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title.byCharWrapping)
                            .font(.fzHeading3)
                            .foregroundStyle(Color.Brand.black0)
                            .lineLimit(1)
                        
                        Text(createdAt.localeDateString)
                            .font(.fzMain)
                            .foregroundStyle(Color.Grayscale.gray6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("NavRightIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
                .padding(16)
                
                Divider()
                    .background(Color.Grayscale.gray2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct NoticeListScreen: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @StateObject
    var viewModel = NoticeListViewModel()
    
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notices) { notice in
                    NoticeListItem(title: notice.title, createdAt: notice.parsedCreatedAt) {
                        navigate(to: notice.id)
                    }
                    .onAppear {
                        // Load more when last item appears
                        if notice.id == viewModel.notices.last?.id {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                }
                
                // Loading indicator
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading && viewModel.notices.isEmpty {
                ProgressView()
            }
        }
        .navigationTitle(NSLocalizedString("ui.notice.list.page_title", comment: "공지사항"))
        .onAppear {
            Task {
                await viewModel.fetchNotices()
            }
        }
    }
    
    func navigate(to noticeId: String) {
        appState.navState.append(.noticeDetail(noticeId: noticeId))
    }
}

extension SimpleNotice {
    var parsedCreatedAt: Date {
        return created_at.asISO8601Date!
    }
}

#Preview {
    NoticeListScreen()
        .environmentObject(RootAppState())
}
