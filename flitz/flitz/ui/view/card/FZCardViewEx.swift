//
//  DummyCard.swift
//  Flitz
//
//  Created by Gyuhwan Park on 12/31/24.
//

import SwiftUI

@MainActor
class FZCardViewExViewModel: ObservableObject {
    let logger = createFZOSLogger("FZCardViewExViewModel")
    
    @Published
    var world: FZCardViewWorld
    
    @Published
    var cards: [String: Flitz.Card] = [:]
    
    @Published
    var worldCards: [String: FZCardViewCardInstance] = [:]
    
    init() {
        self.world = FZCardViewWorld()
        self.world.setup()
    }
    
    func addCard(_ card: Flitz.Card, forId: String) {
        guard !self.cards.keys.contains(forId) else {
            print("Card with ID \(forId) already exists.")
            return
        }
        
        let instance = self.world.spawn(card: card)
        
        instance.updateContent()
        
        self.cards[forId] = card
        self.worldCards[forId] = instance
        
        print("Card with ID \(forId) added successfully.")
    }
}

struct FZCardViewEx: View {
    @StateObject
    var viewModel = FZCardViewExViewModel()
    
    var body: some View {
        VStack {
            FZCardView(world: $viewModel.world, enableGesture: true, gestureRecognizer: nil)
            // .displayCard(card, to: $world)
            Button("Add Card") {
                let newCard = Flitz.Card()
                let uuid = UUID().uuidString
                
                viewModel.addCard(newCard, forId: uuid)
            }
        }
    }
}

#Preview {
    VStack {
        FZCardViewEx()
    }
    .background(.yellow)
}
