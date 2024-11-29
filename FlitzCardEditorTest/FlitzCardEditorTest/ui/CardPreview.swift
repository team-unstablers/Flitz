//
//  CardPreview.swift
//  FlitzCardEditorTest
//
//  Created by Gyuhwan Park on 11/29/24.
//

import SwiftUI

struct CardPreviewTest: View {
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
    
    var body: some View {
        VStack {
            FZCardView(world: $world)
                .displayCard($card, to: $world, showNormalMap: $showNormalMap)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 0)
            HStack {
                Button("show normal map") {
                    showNormalMap.toggle()
                }
            }
        }
        .onAppear {
            self.fetchCard()
        }
    }
    
    func fetchCard() {
        let client = FZAPIClient(context: FZAPIContext.stored!)
        Task {
            do {
                let card = try await client.card(by: cardId)
                
                DispatchQueue.main.async {
                    self.card = card.content
                }
            } catch {
                print(error)
            }
        }
    }
}
