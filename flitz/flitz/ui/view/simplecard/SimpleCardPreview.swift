//
//  SimplecardPreview.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/4/24.
//

import SwiftUI

struct SimpleCardPreview: View {
    @Environment(\.fzAssetsLoader)
    var assetsLoader: AssetsLoader
    
    @Binding
    var client: FZAPIClient
    
    var cardId: String
    
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
            if let cardMeta = cardMeta {
                HStack {
                    Text("\(cardMeta.id)")
                }
            }
            HStack {
                Button("show normal map") {
                    showNormalMap.toggle()
                }
                
                Button("set card as main") {
                    setCardAsMain()
                }
            }
            
            FZCardView(world: $world, enableGesture: false)
                .displayCard($card, to: $world, showNormalMap: $showNormalMap)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
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
