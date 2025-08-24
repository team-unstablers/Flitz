//
//  ManageUserBlock.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/20/25.
//

import SwiftUI

@MainActor
class ManageUserBlockViewModel: ObservableObject {
    @Published var blocks: [FZUserBlock] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    
    private var currentPage: Paginated<FZUserBlock>?
    private var apiClient: FZAPIClient?
    
    func configure(with apiClient: FZAPIClient) {
        self.apiClient = apiClient
        Task {
            await loadBlockedUsers()
        }
    }
    
    func loadBlockedUsers() async {
        guard let apiClient = apiClient, !isLoading else { return }
        
        isLoading = true
        do {
            let page = try await apiClient.blocksList()
            self.currentPage = page
            self.blocks = page.results
            self.hasMoreData = page.next != nil
        } catch {
            print("Failed to load blocked users: \(error)")
        }
        isLoading = false
    }
    
    func loadMore() async {
        guard let apiClient = apiClient,
              let currentPage = currentPage,
              let nextUrl = currentPage.next else { return }
        
        do {
            guard let page = try await apiClient.nextPage(currentPage) else {
                return
            }
            self.currentPage = page
            self.blocks.append(contentsOf: page.results)
            self.hasMoreData = page.next != nil
        } catch {
            print("Failed to load more blocked users: \(error)")
        }
    }
    
    func unblockUser(_ userId: String) async {
        guard let apiClient = apiClient else { return }
        
        do {
            try await apiClient.unblockUser(id: userId)
            self.blocks.removeAll { $0.blocked_user.id == userId }
        } catch {
            print("Failed to unblock user: \(error)")
        }
    }
}

struct ManageUserBlockScreen: View {
    @EnvironmentObject var appState: RootAppState
    @StateObject private var viewModel = ManageUserBlockViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.blocks.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if viewModel.blocks.isEmpty {
                    VStack(spacing: 8) {
                        Text("차단된 사용자가 없어요")
                            .font(.heading2)
                            .bold()
                            .foregroundStyle(Color.Grayscale.gray8)
                        
                        Text("차단된 사용자와는 카드 교환 및 대화가 불가능해요.")
                            .multilineTextAlignment(.center)
                            .font(.main)
                            .foregroundStyle(Color.Grayscale.gray7)
                    }
                }
                
                FZInfiniteScrollView(
                    data: viewModel.blocks,
                    hasMoreData: $viewModel.hasMoreData,
                    loadingView: {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    },
                    onLoadMore: {
                        await viewModel.loadMore()
                    }
                ) { block in
                    UserBlockItem(block: block) {
                        Task {
                            await viewModel.unblockUser(block.blocked_user.id)
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadBlockedUsers()
                }
            }
        }
        .navigationTitle("차단된 사용자")
        .onAppear {
            viewModel.configure(with: appState.client)
        }
    }
}
