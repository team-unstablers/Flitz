//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct WaveCardPreview: View {
    @EnvironmentObject
    var appState: RootAppState
    
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @Binding
    var client: FZAPIClient
    
    var distributionId: String
    
    var cardId: String
    
    var dismissHandler: () -> Void
    
    @State
    var world: FZCardViewWorld = {
        let world = FZCardViewWorld()
        world.setup()
        
        return world
    }()
    
    
    @State
    var showNormalMap: Bool = false
    
    @State
    var card: Flitz.Card?
    
    @State
    var cardMeta: FZCard?
    
    var body: some View {
        VStack {
            FZCardView(world: $world, enableGesture: true)
                .displayCard($card, to: $world, showNormalMap: $showNormalMap)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
            ECController(distributionId: distributionId) { _ in
                dismissHandler()
            }
                .offset(x: 0, y: -60)
        }
        .onAppear {
            self.fetchCard()
        }
    }
    
    func fetchCard() {
        Task {
            do {
                let card = try await client.card(by: cardId)
                do {
                    try await assetsLoader.resolveAll(from: card.content)
                } catch {
                    print(error)
                }
                
                DispatchQueue.main.async {
                    self.card = card.content
                    self.cardMeta = card
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setCardAsMain() {
        Task {
            do {
                try await client.setCardAsMain(which: cardId)
            } catch {
                print(error)
            }
        }
    }
}
