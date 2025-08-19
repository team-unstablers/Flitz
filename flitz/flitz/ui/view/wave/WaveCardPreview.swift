//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

@MainActor
class WaveCardPreviewViewModel: ObservableObject {
    @Published
    var world: FZCardViewWorld
    
    @Published
    var cardInstance: FZCardViewCardInstance? = nil
    
    init() {
        self.world = FZCardViewWorld()
        self.world.setup()
    }
    
    func setup(with card: FZCard) async {
        try? await AssetsLoader.global.resolveAll(from: card.content)
        
        self.cardInstance = self.world.spawn(card: card.content, forId: card.id)
        self.cardInstance?.updateContent()
    }
}
    

struct WaveCardPreview: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @Binding
    var client: FZAPIClient
    
    let distribution: FZCardDistribution
    var dismissHandler: () -> Void
    
    @StateObject
    var viewModel = WaveCardPreviewViewModel()
   
    var body: some View {
        ZStack(alignment: .bottom) {
            FZCardView(world: $viewModel.world, enableGesture: true)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
                .onTapGesture {
                    appState.currentModal = .userProfile(userId: distribution.card.user!.id)
                }
                .if (distribution.reveal_phase == .blurry) { view in
                    view.blur(radius: 16)
                }
            
            // 이거 여기가 아니라 부모에 있어야 됨
            if distribution.reveal_phase == .revealed {
                ECController(distributionId: distribution.id) { _ in
                    dismissHandler()
                }
                    .offset(x: 0, y: -60)
            }
        }
        .onAppear {
            Task {
                await self.viewModel.setup(with: self.distribution.card)
            }
        }
    }
}
