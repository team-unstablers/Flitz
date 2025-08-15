//
//  CardListManage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import SwiftUI

@MainActor
class WaveCardManagerViewModel: ObservableObject {
    @Published
    var distributions: [FZCardDistribution] = []
    
    @Published
    var selection: String?
    
    var client: FZAPIClient = RootAppState.shared.client
    
    /// 내 카드 목록을 가져옵니다.
    func fetchDistributions() async {
        do {
            let distributions = try await self.client.receivedCards()
            
            self.distributions = distributions.results
            self.selection = distributions.results.first?.id
        } catch {
            // FIXME
            print(error)
        }
    }
}

struct WaveCardManagerView: View {
    @StateObject
    var viewModel = WaveCardManagerViewModel()
    
    var body: some View {
        VStack {
            if viewModel.distributions.isEmpty {
                NoCardsAvailable(reason: .noCardsExchanged)
            } else {
                TabView(selection: $viewModel.selection) {
                    ForEach(viewModel.distributions) { distribution in
                        WaveCardPreview(client: $viewModel.client,
                                        distributionId: distribution.id,
                                        cardId: distribution.card.id) {
                            viewModel.distributions.removeAll { $0.id == distribution.id }
                        }
                            .tag(distribution.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchDistributions()
            }
        }
    }
}
