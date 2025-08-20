//
//  ManageUserBlock.swift
//  Flitz
//
//  Created by Gyuhwan Park on 8/20/25.
//

import SwiftUI

@MainActor
class ManageUserBlockViewModel: ObservableObject {
    @Published
    var blocks: [FZUserBlock] = []
    
    func loadBlockedUsers() async {
        #warning("pagination")
        let client = RootAppState.shared.client
        
        do {
            let blocks = try await client.blocksList()
            
            self.blocks = blocks.results
        } catch {
            print("Failed to load blocked users: \(error)")
        }
    }
    
    func unblockUser(_ userId: String) async {
        let client = RootAppState.shared.client
        
        do {
            try await client.unblockUser(id: userId)
            self.blocks.removeAll { $0.blocked_user.id == userId }
        } catch {
            print("Failed to unblock user: \(error)")
        }
    }
}

struct ManageUserBlockScreen: View {
    @StateObject
    private var viewModel = ManageUserBlockViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.blocks, id: \.id) { block in
                    UserBlockItem(block: block) {
                        Task {
                            await viewModel.unblockUser(block.blocked_user.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("차단된 사용자")
        .onAppear() {
            Task {
                await viewModel.loadBlockedUsers()
            }
        }
    }
}
