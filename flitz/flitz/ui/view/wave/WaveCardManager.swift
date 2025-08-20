//
//  CardListManage.swift
//  Flitz
//
//  Created by Gyuhwan Park on 1/5/25.
//

import SwiftUI
import SwiftUIX

@MainActor
class WaveCardManagerViewModel: ObservableObject {
    @Published
    var distributions: [FZCardDistribution] = []
    
    @Published
    var cardInstances: [FZCardViewCardInstance] = []
    
    var current: FZCardDistribution? {
        distributions.first
    }
    
    @Published
    var selection: String?
    
    @Published
    var world: FZCardViewWorld
    
    var client: FZAPIClient = RootAppState.shared.client
    
    init() {
        self.world = FZCardViewWorld()
        self.world.setup()
    }
    
    /// 내 카드 목록을 가져옵니다.
    func fetchDistributions() async {
        await self.clearCards()
        
        do {
            let distributions = try await self.client.receivedCards()
            
            self.distributions = distributions.results
            self.selection = distributions.results.first?.id
            
            await self.spawnCards()
        } catch {
            // FIXME
            print(error)
        }
    }
    
    func clearCards() async {
        for instance in self.cardInstances {
            instance.destroy()
        }
        
        self.cardInstances.removeAll()
    }
    
    func spawnCards() async {
        let assetsLoader = AssetsLoader.global
        
        for distribution in distributions {
            let cardInstance = self.world.spawn(card: distribution.card.content, forId: distribution.id)
            
            cardInstance.shouldDisplayBlurry = distribution.reveal_phase != .revealed
            
            try? await assetsLoader.resolveAll(from: distribution.card.content)
            cardInstance.updateContent()
            
            self.cardInstances.append(cardInstance)
        }
    }
}

struct WaveCardPreview: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @StateObject
    var viewModel: WaveCardManagerViewModel
   
    var body: some View {
        if let distribution = viewModel.current {
            ZStack(alignment: .bottom) {
                FZCardView(world: $viewModel.world, enableGesture: true)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                    .onTapGesture {
                        guard distribution.reveal_phase == .revealed else {
                            return
                        }
                        
                        appState.currentModal = .userProfile(userId: distribution.card.user!.id)
                    }
                
                // 이거 여기가 아니라 부모에 있어야 됨
                if distribution.reveal_phase == .revealed {
                    ECController(distributionId: distribution.id) { _ in
                        viewModel.world.pop()
                        viewModel.distributions.removeAll { $0.id == distribution.id }
                        viewModel.cardInstances.removeAll { $0.id == distribution.id }
                    }
                    .offset(x: 0, y: -60)
                }
                
                if distribution.reveal_phase == .blurry {
                    VStack() {
                        Text("아직은 카드를 볼 수 없어요")
                            .font(.heading2)
                            .bold()
                            .foregroundStyle(Color.Grayscale.gray8)
                        
                        Text("시간이 지나면 카드를 볼 수 있게 될 거에요.\n조금만 기다려 주세요!")
                            .multilineTextAlignment(.center)
                            .font(.main)
                            .foregroundStyle(Color.Grayscale.gray7)
                    }
                    .padding()
                    .background {
                        BlurEffectView(style: .extraLight)
                    }
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.24), radius: 16)
                    .padding(.bottom, 32)
                }
            }
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
                WaveCardPreview(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchDistributions()
            }
        }
    }
}
